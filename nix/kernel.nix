{ stdenv, fetchurl, pkg-config, bc, perl, flex, bison, riscv-gnu-toolchain }:
stdenv.mkDerivation rec {
  pname = "myToyKernel";
  version = "6.5.2";
  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
    hash = "sha256-ICfhQFfVaK093BANrfTIhTpJsDEnBHimHYj2ARVyZQ8=";
  };
  nativeBuildInputs = [
    pkg-config
    bc
    perl
    flex
    bison

    riscv-gnu-toolchain
  ];
  enableParallelBuilding = true;
  hardeningDisable = [
    "strictoverflow"
  ];
  makeFlags = [
    "ARCH=riscv"
    "CROSS_COMPILE=riscv64-unknown-linux-gnu-"
    "defconfig"
    "all"
  ];
  installPhase = ''
    mkdir -p $out/bin
    mv arch/riscv/boot/Image $out/bin/Image
  '';
}
