{pkgs ? import <nixpkgs> {}, ...}: let
  libs = with pkgs.stdenv.cc; {
    ccLib = cc.lib;
    libc = libc;
    libcDev = libc.dev;
    libcStatic = libc.static;
    libgcc = cc.libgcc;
  };
in
  pkgs.mkShell {
    name = "rust-dev-gcc";

    # Make clang aware of a few headers
    BINDGEN_EXTRA_CLANG_ARGS = ''-isystem ${libs.libcDev}/include'';

    # libc dynamic libraries
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      libs.ccLib
      libs.libc
      libs.libgcc
      pkgs.zlib
    ];

    # libc static libraries
    LIBRARY_PATH = pkgs.lib.makeLibraryPath [libs.libcStatic];

    nativeBuildInputs = [
      pkgs.cmake
      pkgs.curl
      pkgs.python3
      pkgs.pkg-config
      (pkgs.writeShellScriptBin "nvim" "exec env --unset=LD_LIBRARY_PATH /home/max/.nix-profile/bin/nvim")
    ];

    shellHook = ''
      alias x_wrapped="setarch $(uname -m) $(pwd)/x"
      no_randomize=$(setarch --show | grep "ADDR_NO_RANDOMIZE")
      if [ -n no_randomize ];
      then
        echo 'The ADDR_NO_RANDOMIZE flag is set.'
        echo "Use the \"setarch\" program to unset this flag: \"setarch $(uname -m) ./x ...\"."
        echo "Alternatively, you can use the following alias: \"x_wrapped\"."
      fi;
    '';
  }
