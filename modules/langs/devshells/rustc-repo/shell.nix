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

    BINDGEN_EXTRA_CLANG_ARGS = ''-isystem ${libs.libcDev}/include'';

    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
    ];

    LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.libc.static or pkgs.glibc.static
    ];

    nativeBuildInputs = [
      pkgs.cmake
      pkgs.curl
      pkgs.python3
      pkgs.pkg-config
    ];

    buildInputs = [
      pkgs.zlib
      pkgs.openssl
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
