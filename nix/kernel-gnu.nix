{ stdenv, fetchurl, pkg-config, bc, perl, flex, bison }:
stdenv.mkDerivation rec {
  pname = "myToyKernel-GNU";
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
  ];
  enableParallelBuilding = true;
  hardeningDisable = [
    "strictoverflow"
  ];
  makeFlags = [
    "ARCH=riscv"
    "LLVM=1"
    "defconfig"
    "all"
  ];
  installPhase = ''
    mkdir -p $out/bin
    mv arch/riscv/boot/Image $out/bin/Image
  '';
}
