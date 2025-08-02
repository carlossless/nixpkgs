{
  lib,
  fetchFromGitHub,
  rustPlatform,
  src,
  stdenv,
}:
let
  cross = import ../../../.. {
    system = stdenv.hostPlatform.system;
    crossSystem = lib.systems.examples.riscv32-embedded // {
      useLLVM = true;
      linker = "lld";
      rust.rustcTarget = "riscv32imac-unknown-none-elf";
    };
  };

  inherit (cross) rustPlatform;
in
rustPlatform.buildRustPackage {
  pname = "moondancer";
  version = "0.2.3";

  src = src;

  sourceRoot = "${src.name}/firmware";

  cargoHash = "sha256-G/9evh3G1xNRaaEh6lgDp3hnVlB3MaCwXuhGnGJCd0Q=";

  auditable = false;

  # RUSTFLAGS = "-C link-arg=-Tmemory.x -C link-arg=-Tlink.xd";

  doCheck = false;

  meta = {
    platforms = ["riscv32-none"];
  };
}
