final: prev: {
  myKernel = final.callPackage ./nix/kernel.nix {};
  riscv-gnu-toolchain = final.callPackage ./nix/riscv-gnu-toolchain.nix {};
  myInitrd = final.callPackage ./nix/initrd.nix {};
  myRustToolchain = final.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" ];
    targets = [ "riscv64gc-unknown-linux-gnu" ];
  };
}
