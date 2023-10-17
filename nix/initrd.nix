{ cpio, myRustToolchain, stdenv, riscv-gnu-toolchain, rustPlatform }:
with rustPlatform;
let
  cargoDeps = fetchCargoTarball {
    src = ../pid1;
    name = "pid1-deps";
    hash = "sha256-bmasRu70zixsQZ7OktVwMGOy1qcPvtl/Az3rJiF5FU4=";
  };
in
stdenv.mkDerivation {
  inherit cargoDeps;

  pname = "myInitrd";
  version = "v0.1.0";

  srcs = [
    ../pid1
    ../shell
  ];
  sourceRoot = ".";
  unpackPhase = ''
    local srcArray=( $srcs )
    for src in ''${srcArray[@]}; do
      cp -rP "$src" "$(stripHash $src)"
    done

    chmod -R u+w -- ./*

    runHook postUnpack
  '';

  nativeBuildInputs = [
    cpio
    cargoSetupHook
    myRustToolchain
    riscv-gnu-toolchain
  ];

  cargoRoot = "pid1";

  buildPhase = ''
    mkdir -p initrd
    initrdDir="$PWD/initrd"

    # Use riscv-gnu-toolchain to cross compile, and link statically
    export RUSTFLAGS='-C target-feature=+crt-static -C linker=riscv64-unknown-linux-gnu-gcc'
    build() {
      pushd "$1"
      cargo build --release --target riscv64gc-unknown-linux-gnu
      cp target/riscv64gc-unknown-linux-gnu/release/"$1" "$initrdDir"
      popd
    }

    build shell
    build pid1
    unset RUSTFLAGS

    cd "$initrdDir"
    mv pid1 init
    cat <<EOF | cpio -o -H newc > initramfs.cpio
    init
    shell
    EOF
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp $initrdDir/initramfs.cpio $out/lib
  '';
}
