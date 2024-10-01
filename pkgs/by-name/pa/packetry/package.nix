{ cairo
, darwin
, fetchFromGitHub
, gdk-pixbuf
, glib
, graphene
, gtk4
, lib
, libusb1
, pango
, pkg-config
, rustPlatform
, stdenv
, wrapGAppsHook4
}:

rustPlatform.buildRustPackage rec {
  pname = "packetry";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "packetry";
    rev = "v${version}";
    hash = "sha256-FlimHJS3hwB2Tkulb8uToKFe165uv/gFxJ4uezVNka4=";
  };

  cargoHash = "sha256-n1hPoSUEFUGpEUOiuirSbeAnU+qiENDg4XyN5Jkjo/Y=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    graphene
    gtk4
    libusb1
    pango
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
  ];

  doCheck = false;

  meta = with lib; {
    description = "USB 2.0 protocol analysis application for use with Cynthion.";
    homepage = "https://github.com/greatscottgadgets/packetry";
    license = licenses.bsd3;
    maintainers = with maintainers; [ carlossless ];
  };
}
