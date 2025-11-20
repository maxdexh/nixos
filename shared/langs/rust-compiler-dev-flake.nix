# NOTE: Use this flake when compiling rustc.
# https://discourse.nixos.org/t/building-rustc-in-nixos/20938/4
{
  description = "A flake for rust development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        libs = with pkgs.stdenv.cc; {
          ccLib = cc.lib;
          libc = libc;
          libcDev = libc.dev;
          libcStatic = libc.static;
          libgcc = cc.libgcc;
        };
      in
        with pkgs; {
          devShells.default = mkShell {
            name = "rust-dev-gcc";

            # Make clang aware of a few headers
            BINDGEN_EXTRA_CLANG_ARGS = ''-isystem ${libs.libcDev}/include'';

            # libc dynamic libraries
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              libs.ccLib
              libs.libc
              libs.libgcc
              zlib
            ];

            # libc static libraries
            LIBRARY_PATH = lib.makeLibraryPath [libs.libcStatic];

            nativeBuildInputs = [
              cmake
              curl
              python3
              pkg-config
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
          };
        }
    );
}
