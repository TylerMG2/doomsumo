{
  description = "Minimal Bevy WASM project setup for Extreme Bevy tutorial";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rust = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "wasm32-unknown-unknown" ];
        };

        nativeDeps = with pkgs; [
          pkg-config
          cmake
          wasm-server-runner
          cargo-watch
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ rust ] ++ nativeDeps;

          RUST_BACKTRACE = "1";
        };
      }
    );
}
