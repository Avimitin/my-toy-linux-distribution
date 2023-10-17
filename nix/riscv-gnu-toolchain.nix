{ fetchFromGitHub, fetchgit, stdenv, curl, texinfo, bison, flex, gmp, mpfr, libmpc, python3, perl, flock, expat }:
let
  binutilsSrc = fetchgit {
    url = "https://sourceware.org/git/binutils-gdb.git";
    rev = "675b9d612cc59446e84e2c6d89b45500cb603a8d"; #v2.41
    hash = "sha256-bbzw4QFdlTQIknRb7rHtK9a7kWsOBAKHvGeUKoDtGB4=";
  };
  gccSrc = fetchgit {
    url = "https://gcc.gnu.org/git/gcc.git";
    rev = "c891d8dc23e1a46ad9f3e757d09e57b500d40044"; # 13.2.0
    hash = "sha256-AAu/jE3MlMgvd+xagn9ujJ8PpKJZ16iZXhU9QxNRZSk=";
  };
  glibcSrc = fetchgit {
    url = "https://sourceware.org/git/glibc.git";
    rev = "36f2487f13e3540be9ee0fb51876b1da72176d3f"; # 2.38
    hash = "sha256-o/lKFroKT9OmQunHi84Zklb48LNJAzp7XVXeMc8FEGg=";
  };
  gdbSrc = fetchgit {
    url = "https://sourceware.org/git/binutils-gdb.git";
    rev = "662243de0e14a4945555a480dca33c0e677976eb";
    hash = "sha256-LgBvtrFsw/s7cKmb3s/HUK22PWuRuqlhS0Y7WWgzzs4=";
  };
in
stdenv.mkDerivation rec {
  pname = "riscv-gnu-toolchain";
  version = "unstable-2023-10-13";
  srcs =
    (fetchFromGitHub {
      owner = "riscv-collab";
      repo = pname;
      rev = "6b1324367b879a9b89437846827b48151b26b412";
      sha256 = "sha256-CKGVp/icKi1jqWDtAKsRsr/6BwTQWbVU4y5AewkGzFU=";
    });

  postUnpack = ''
    copy() {
      cp -pr --reflink=auto -- "$1" "$2"
    }

    rm -r $sourceRoot/{binutils,gcc,glibc,gdb}

    copy ${binutilsSrc} $sourceRoot/binutils
    copy ${gccSrc} $sourceRoot/gcc
    copy ${glibcSrc} $sourceRoot/glibc
    copy ${gdbSrc} $sourceRoot/gdb

    chmod -R u+w -- "$sourceRoot"
  '';

  nativeBuildInputs = [
    curl
    perl
    python3
    texinfo
    bison
    flex
    gmp
    mpfr
    libmpc

    flock # required for installing file
    expat # glibc
  ];

  enableParallelBuilding = true;

  configureFlags = [
    "--with-arch=rv64gc"
    "--with-abi=lp64d"
  ];

  postConfigure = ''
    # nixpkgs will set those value to bare string "ar", "objdump"...
    # however we are cross-compiling, we must let $CC to determine which bintools to use.
    unset AR AS LD OBJCOPY OBJDUMP
  '';

  # RUN: make linux
  makeFlags =
    [
      # Don't auto update source
      "GCC_SRC_GIT="
      "BINUTILS_SRC_GIT="
      "GLIBC_SRC_GIT="
      "GDB_SRC_GIT="

      # build target
      "linux"

      # Install to nix out dir
      "INSTALL_DIR=${placeholder "out"}"
    ];

  # -Wno-format-security
  hardeningDisable = [ "format" ];

  dontPatchELF = true;
  dontStrip = true;
}
