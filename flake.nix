{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    rust-overlay,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        buildTarget = "wasm32-unknown-unknown";

        pkgs = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default];
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = [buildTarget];
          extensions = ["rust-src"];
        };

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            rustToolchain
            pkgs.pkg-config
            pkgs.openssl
            pkgs.cargo-watch
            pkgs.wasm-pack
            pkgs.wasm-bindgen-cli
            pkgs.alsa-lib
            pkgs.rust-analyzer
            pkgs.udev

            # Add wasm-server-runner from source
            (rustPlatform.buildRustPackage {
              pname = "wasm-server-runner";
              version = "1.0.0";
              src = pkgs.fetchFromGitHub {
                owner = "jakobhellermann";
                repo = "wasm-server-runner";
                rev = "v1.0.0";
                sha256 = "sha256-3ARVVA+W9IS+kpV8j5lL/z6/ZImDaA+m0iEEQ2mSiTw=";
              };
              cargoHash = "sha256-FrnCmfSRAePZuWLC1/iRJ87CwLtgWRpbk6nJLyQQIT8=";
            })

            # Matchbox server for wasm
            (rustPlatform.buildRustPackage {
              pname = "matchbox-server";
              version = "0.12.0";
              src = pkgs.fetchFromGitHub {
                owner = "johanhelsing";
                repo = "matchbox";
                rev = "v0.12.0";
                sha256 = "sha256-zyA7qkBFuIEL+jxnfRzt82kEl/P5xIRySA3V0Qv2cN0=";
              };
              cargoBuildFlags = ["-p" "matchbox_server"];
              doCheck = false;
              cargoHash = "sha256-sbcZWLEgRga4iYiB2lBlZsztNjQzWWEIJHfzHovw3wU=";
            })
          ];
          shellHook = ''
            echo "Welcome to the doomsumo development shell"
          '';
        };
      }
    );
}
