{
  stdenv,
  lib,
  fetchFromGitHub,
  meson,
  pkg-config,
  ninja,
  glib,
  gtk3,
  nemo,
  file-roller,
  cinnamon-translations,
}:

stdenv.mkDerivation rec {
  pname = "nemo-fileroller";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "nemo-extensions";
    rev = version;
    hash = "sha256-39hWA4SNuEeaPA6D5mWMHjJDs4hYK7/ZdPkTyskvm5Y=";
  };

  sourceRoot = "${src.name}/nemo-fileroller";

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [
    glib
    gtk3
    nemo
  ];

  postPatch = ''
    substituteInPlace src/nemo-fileroller.c \
      --replace "file-roller" "${lib.getExe file-roller}" \
      --replace "GNOMELOCALEDIR" "${cinnamon-translations}/share/locale"
  '';

  PKG_CONFIG_LIBNEMO_EXTENSION_EXTENSIONDIR = "${placeholder "out"}/${nemo.extensiondir}";

  meta = with lib; {
    homepage = "https://github.com/linuxmint/nemo-extensions/tree/master/nemo-fileroller";
    description = "Nemo file roller extension";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    teams = [ teams.cinnamon ];
  };
}
