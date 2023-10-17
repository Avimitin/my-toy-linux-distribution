{
  description = "Generic devshell setup";

  inputs = {
    # The nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utility functions
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    let
      overlays = [(import ./overlay.nix) (import rust-overlay)];
      pkgsForSys = system: import nixpkgs { inherit system overlays; };
      perSystem = (system:
        let
          pkgs = pkgsForSys system;
        in
        {
          devShells.dev = pkgs.mkShell {
            buildInputs = with pkgs; [
              riscv-gnu-toolchain
              rust-analyzer-unwrapped
              myRustToolchain
            ];

            env = {
              RUST_SRC_PATH = "${pkgs.myRustToolchain}/lib/rustlib/src/rust/library";
            };
          };

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              qemu
              myInitrd
            ];
            env = {
              KERNEL_BIN_PATH = "${pkgs.myKernel}/bin/Image";
              INITRD_PATH = "${pkgs.myInitrd}/lib/initramfs.cpio";
            };
          };

          formatter = pkgs.nixpkgs-fmt;
          packages.initrd = pkgs.myInitrd;
        });
    in
    {
      # Other system-independent attr
    } //

    flake-utils.lib.eachDefaultSystem perSystem;
}
