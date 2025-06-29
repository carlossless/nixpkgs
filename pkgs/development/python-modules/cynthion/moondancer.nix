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
      rust.rustcTarget = "riscv32imac-unknown-none-elf";
    };
  };

  inherit (cross) rustPlatform;

in
rustPlatform.buildRustPackage {
  pname = "moondancer";
  version = "0.2.0";

  src = src;

  sourceRoot = "${src.name}/firmware";

  cargoHash = "sha256-qz5y6fYVq1apKAbJoUci5qbYN/evhuGJTgwNeTzmtK4=";

  cargoPatches = [
    # a patch file to add/update Cargo.lock in the source code
    ./add-Cargo.lock.patch
  ];

  auditable = false;

  RUSTFLAGS = "-C link-arg=-Tmemory.x -C link-arg=-Tlink.xd";

  doCheck = false;

  meta = {
    platforms = [ "riscv32-none" ];
  };
}
