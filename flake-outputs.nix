inputs: let
  CONTEXTS = {
    HOME = "hm";
    SYSTEM = "os";
    MIXED = "mixed";
  };

  HOST-INFOS = {
    framework = {
      modulePath = "./hosts/framework";
      isNixOS = true;
      system = "x86_64-linux";
    };
    desktop = {
      modulePath = "./hosts/desktop";
      isNixOS = true;
      system = "x86_64-linux";
    };
  };

  PARTIAL-Gs =
    lib.mapAttrsToList (name: info: {
      inherit inputs;
      host = info // {inherit name;};
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${info.system};
    })
    HOST-INFOS;

  attrs-at-or-empty = attr-name: attrs:
    if attrs?${attr-name}
    then attrs.${attr-name}
    else {};
  G-add-context = part-G: context:
    part-G
    // {
      ctx = {
        name = context;
        pick = attrs: attrs.${context};

        mkPickMerge = attrs:
          lib.mkMerge [
            (attrs-at-or-empty context attrs)
            (attrs-at-or-empty CONTEXTS.MIXED attrs)
          ];
      };
    };

  lib = inputs.nixpkgs.lib;

  find-imports-in = relpath: let
    basepath = ./${relpath};
    candidates = lib.pipe basepath [
      lib.filesystem.listFilesRecursive
      (map toString)
      (builtins.filter (lib.strings.hasSuffix ".nix"))
    ];
    filter-kind = kind: let
      imports = builtins.filter (path: lib.strings.hasSuffix ".${kind}.nix" path || lib.strings.hasSuffix "/${kind}.nix" path) candidates;
    in
      builtins.trace "Auto-importing ${toString (builtins.length imports)} of kind '${kind}' in ${relpath}" imports;

    mixed = filter-kind "mixed";
  in
    kind: mixed ++ (filter-kind kind);

  find-host-imports = let
    find-host-agnostic = find-imports-in "./shared";
  in
    G: let
      find-host-specific = find-imports-in G.host.modulePath;
    in
      kind: builtins.concatMap (find: find kind) [find-host-specific find-host-agnostic];

  nixos-system = part-G: let
    find-imports = find-host-imports part-G;
  in {
    system = part-G.host.system;

    modules = [
      {networking.hostName = part-G.host.name;}
      # Configuration for nixpkgs, such as overlays. Only import from system since useGlobalPkgs = true
      ./nixpkgs-conf
      # System base
      {
        imports = find-imports CONTEXTS.SYSTEM;
        system.stateVersion = "25.05";
      }
      # Users
      inputs.home-manager.nixosModules.home-manager
      {
        users.users.max = {
          isNormalUser = true;
          description = "Max";
          extraGroups = ["networkmanager" "wheel"];
        };

        # Home Manager user config
        home-manager.users.max = {
          imports = find-imports CONTEXTS.HOME;
          home.stateVersion = "25.05";
        };

        home-manager = {
          useGlobalPkgs = true;
          verbose = true;
          extraSpecialArgs.G = G-add-context part-G CONTEXTS.HOME;
        };
      }
    ];

    specialArgs.G = G-add-context part-G CONTEXTS.SYSTEM;
  };
in {
  nixosConfigurations = lib.pipe PARTIAL-Gs [
    (builtins.filter (G: G.host.isNixOS))
    (map (G: {
      ${G.host.name} = lib.nixosSystem (nixos-system G);
    }))
    lib.attrsets.mergeAttrsList
  ];
}
