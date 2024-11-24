{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  pkg-config,
  ninja,
  zlib,
  libpng,
  libjpeg,
  curl,
  SDL2,
  openalSoft,
  libogg,
  libvorbis,
  libXi,
  wayland,
  wayland-protocols,
  libdecor,
  ffmpeg,
  wayland-scanner,
  makeBinaryWrapper,
  versionCheckHook,
  copyDesktopItems,
  makeDesktopItem,
  desktopToDarwinBundle,
  x11Support ? stdenv.hostPlatform.isLinux,
  waylandSupport ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "q2pro";
  version = "3626"; # git rev-list --count ${src.rev}

  src = fetchFromGitHub {
    owner = "skullernet";
    repo = "q2pro";
    rev = "cd3f69e66b83931c2c34841099784fb0e91d7dad";
    hash = "sha256-OTrya0OF4D0XbW1OtApAx5F+XqLoCIUsn2OvwCHwVVk=";
  };

  # build date is displayed in the game's console
  SOURCE_DATE_EPOCH = 1732218854; # git show -s --format=%ct ${src.rev}

  nativeBuildInputs =
    [
      meson
      pkg-config
      ninja
      makeBinaryWrapper
      copyDesktopItems
    ]
    ++ lib.optional waylandSupport wayland-scanner
    ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs =
    [
      zlib
      libpng
      libjpeg
      curl
      SDL2
      libogg
      libvorbis
      ffmpeg
      openalSoft
    ]
    ++ lib.optionals waylandSupport [
      wayland
      wayland-protocols
      libdecor
    ]
    ++ lib.optional x11Support libXi;

  mesonBuildType = "release";

  mesonFlags = [
    (lib.mesonBool "anticheat-server" true)
    (lib.mesonBool "client-gtv" true)
    (lib.mesonBool "packetdup-hack" true)
    (lib.mesonBool "variable-fps" true)
    (lib.mesonEnable "wayland" waylandSupport)
    (lib.mesonEnable "x11" x11Support)
    (lib.mesonEnable "icmp-errors" stdenv.hostPlatform.isLinux)
    (lib.mesonEnable "windows-crash-dumps" false)
  ];

  postPatch = ''
    echo 'r${version}~${builtins.substring 0 8 src.rev}' > VERSION
  '';

  postInstall =
    let
      ldLibraryPathEnvName =
        if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
    ''
      mv -v $out/bin/q2pro $out/bin/q2pro-unwrapped
      makeWrapper $out/bin/q2pro-unwrapped $out/bin/q2pro \
        --prefix ${ldLibraryPathEnvName} : "${lib.makeLibraryPath finalAttrs.buildInputs}"

      install -D ${src}/src/unix/res/q2pro.xpm $out/share/icons/hicolor/32x32/apps/q2pro.xpm
    '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  desktopItems = [
    (makeDesktopItem {
      name = "q2pro";
      desktopName = "Q2PRO";
      exec = if stdenv.hostPlatform.isDarwin then "q2pro" else "q2pro +connect %u";
      icon = "q2pro";
      terminal = false;
      mimeTypes = [
        "x-scheme-handler/quake2"
      ];
      type = "Application";
      categories = [
        "Game"
        "ActionGame"
      ];
    })
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Enhanced Quake 2 client and server focused on multiplayer";
    homepage = "https://github.com/skullernet/q2pro";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ carlossless ];
    platforms = lib.platforms.unix;
    mainProgram = "q2pro";
  };
})
