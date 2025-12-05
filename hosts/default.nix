inputs: let
  DEFAULT_USERS = {
    max = {};
  };
  HOSTS = {
    fw13 = {
      nixOS = true;
    };
    homepc = {
      nixOS = true;
    };
  };

  lib = inputs.nixpkgs.lib;
in lib.mapAttrsToList (host_name: {
  # TODO: Optionally put the other hosts behind mkif for checking
  modulePaths ? [./${host_name}],
  system ? "x86_64-linux",
  nixOS ? false,
  homeDir ? (user: "/home/${user.name}"),
}: let
  mk_user = user_name: {modulePaths ? []}: let
    user = {
      inherit host;
      homeConfigurationName = "${user_name}@${host_name}";
      name = user_name;
      homeDirectory = homeDir user;
      modulePaths = host.modulePaths ++ modulePaths;
    };
  in user;

  host = {
    inherit system nixOS;
    name = host_name;
    modulePaths = modulePaths ++ [../shared];
    users = builtins.mapAttrs mk_user DEFAULT_USERS;
  };
in host) HOSTS
