{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nix profile install nixpkgs/nixpkgs-unstable#packagename
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
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

    host-Gs = lib.pipe HOST-INFOS [
      (lib.mapAttrsToList (name: info: info // {inherit name;}))
      (map (host: {
        inherit inputs;
        inherit host;

        pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
      }))
    ];

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

    G-context-extra = ctx: {
      context = ctx;
      pickCtx = it: it.${ctx};
      mkIfCtxIs = other-ctx: lib.mkIf (ctx == other-ctx);
    };

    nixos-system = G: let
      find-imports = find-host-imports G;
    in {
      system = G.host.system;

      modules = [
        {networking.hostName = G.host.name;}
        # Configuration for nixpkgs, such as overlays. Only import from system since useGlobalPkgs = true
        ./nixpkgs-conf
        # System base
        {
          imports = find-imports "system";
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
            imports = find-imports "home";
            home.stateVersion = "25.05";
          };

          home-manager = {
            useGlobalPkgs = true;
            verbose = true;
            extraSpecialArgs.G = G // G-context-extra "home";
          };
        }
      ];

      specialArgs.G = G // G-context-extra "system";
    };
  in {
    nixosConfigurations = lib.pipe host-Gs [
      (builtins.filter (G: G.host.isNixOS))
      (map (G: {
        ${G.host.name} = lib.nixosSystem (nixos-system G);
      }))
      lib.attrsets.mergeAttrsList
    ];
  };
}
