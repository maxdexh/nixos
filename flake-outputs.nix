inputs: let
  _hosts = {
    framework = {
      nixOS = true;
      hmStandalone = true;
    };
    homepc = {
      nixOS = true;
    };
  };
  _users = {
    max = {};
  };

  overlays = final: prev: {
    # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
    # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
    alejandra = prev.rustPlatform.buildRustPackage {
      pname = "alejandra";
      version = "4.0.0";

      # FIXME: Precompile into github release
      src = builtins.fetchGit {
        url = "https://github.com/maxdexh/alejandra";
        rev = "f8191bf6742d2dccdd73ea204d77111302fc0da8";
      };

      # FIXME: Remove after adjusting tests
      doCheck = false;

      cargoHash = "sha256-IX4xp8llB7USpS/SSQ9L8+17hQk5nkXFP8NgFKVLqKU=";

      meta = {
        license = prev.lib.licenses.unlicense;
        mainProgram = "alejandra";
      };
    };
  };

  mod_kinds = {
    HOME = "hm";
    SYSTEM = "os";
  };

  lib = inputs.nixpkgs.lib;
  cross_lists = f: lib.foldl (fs: args: builtins.concatMap (f: map f args) fs) [f]; # Copy of the deprecated lib.crossLists

  hosts = lib.mapAttrsToList (name: {
    moduleDirs ? [./hosts/${name}],
    system ? "x86_64-linux",
    nixOS ? false,
    hmStandalone ? false,
    termux ? false, # NOTE: unimplemented
    usersDir ? (assert !termux; name: "/home/${name}"),
  }: {
    inherit system name nixOS hmStandalone termux usersDir;
    moduleDirs = assert hmStandalone || nixOS; assert !termux; moduleDirs ++ [./shared];
  }) _hosts;

  users = lib.mapAttrsToList (name: {}: {
    inherit name;
  }) _users;

  configPathToRel = lib.flip lib.pipe [
    (path: assert builtins.isPath path; path)
    toString
    # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
    # Could also be done without the builtin by traversing backwards using
    # `+ "/.."` and using `baseNameOf` to get each path segment.
    builtins.unsafeDiscardStringContext
    (abs: assert lib.hasPrefix "${inputs.self}/" abs; lib.removePrefix "${inputs.self}/" abs)
  ];

  build_special_args = host: mod_kind: {
    inherit host inputs configPathToRel;
    pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
    ctx = {
      os.set = lib.optionalAttrs (mod_kind == mod_kinds.SYSTEM);
      hm.set = lib.optionalAttrs (mod_kind == mod_kinds.HOME);
    };
  };

  # TODO: Use auto-import comments and file extension .auto.nix
  find_auto_imports = basepath: kind: lib.pipe basepath [
    lib.filesystem.listFilesRecursive
    (map toString)
    (builtins.filter (path: lib.hasSuffix ".${kind}.nix" path || lib.hasSuffix "/${kind}.nix" path))
    (imports: builtins.trace "Importing ${toString (builtins.length imports)} ${kind} files from ${configPathToRel basepath}" imports)
  ];

  find_host_auto_imports = host: kind: builtins.concatLists (cross_lists find_auto_imports [host.moduleDirs [kind "mixed"]]);

  nixos_system = host: lib.nixosSystem {
    system = host.system;

    modules = let
      mk_user_sets = mk_val: lib.pipe users [
        (builtins.filter (user: true))
        (map (user: {${user.name} = mk_val user;}))
        lib.attrsets.mergeAttrsList
      ];

      base = {
        networking.hostName = host.name; # see see config.system.name
        imports = find_host_auto_imports host mod_kinds.SYSTEM;
        system.stateVersion = "25.05";
        nixpkgs.overlays = [overlays];
        nixpkgs.config.allowUnfree = true;
        users.users = mk_user_sets (_: {
          isNormalUser = true;
          description = "Max";
          extraGroups = ["networkmanager" "wheel"];
        });
        nix.settings.trusted-users = builtins.attrNames (mk_user_sets (_: null));
      };

      hmModule = {
        # Home Manager user config
        home-manager.users = mk_user_sets (_: {
          imports = find_host_auto_imports host mod_kinds.HOME;
          home.stateVersion = "25.05";
        });

        home-manager = {
          useGlobalPkgs = true; # Also inherits nixpkgs configs
          verbose = true;
          extraSpecialArgs = build_special_args host mod_kinds.HOME;
        };
      };
    in
      [base] ++ lib.optionals (!host.hmStandalone) [inputs.home-manager.nixosModules.home-manager hmModule];

    specialArgs = build_special_args host mod_kinds.SYSTEM;
  };

  standalone_hm_config = host: user: {
    "${user.name}@${host.name}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${host.system};
      extraSpecialArgs = build_special_args host mod_kinds.HOME;
      modules = [
        ({pkgs, ...}: {home.packages = [pkgs.home-manager];}) # NOTE: Bootstrap via nix shell
        {
          imports = find_host_auto_imports host mod_kinds.HOME;
          home.stateVersion = "25.05";
          nixpkgs.overlays = [overlays];
          nixpkgs.config.allowUnfree = true;
          home.username = user.name;
          home.homeDirectory = host.usersDir user.name;
        }
      ];
    };
  };
in {
  nixosConfigurations = lib.pipe hosts [
    (builtins.filter (host: host.nixOS))
    (map (host: {${host.name} = nixos_system host;}))
    lib.attrsets.mergeAttrsList
  ];

  homeConfigurations = lib.pipe [hosts users] [
    (cross_lists standalone_hm_config)
    lib.attrsets.mergeAttrsList
  ];
}
