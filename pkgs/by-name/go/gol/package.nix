{
  lib,
  maven,
  fetchFromGitHub,
  makeWrapper,
  jre,
}:

maven.buildMavenPackage rec {
  pname = "gol";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "clarisma";
    repo = "gol-tool";
    tag = version;
    hash = "sha256-roFtoSpNByNVGkl7ESt5O6b4voVzX8Nbow1dI6Sqgss";
  };

  mvnHash = "sha256-lKmoftSkyyb/pIthrsJaZ3p9l5V5K3FdK6sOBoZyhe8";
  mvnParameters = "compile assembly:single -Dmaven.test.skip=true";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp target/gol-tool-${version}-jar-with-dependencies.jar $out/lib/gol-tool.jar

    makeWrapper ${jre}/bin/java $out/bin/gol \
      --add-flags "-cp $out/lib/gol-tool.jar" \
      --add-flags "com.geodesk.gol.GolTool"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line utility for creating and managing Geographic Object Libraries";
    longDescription = ''
      Use the GOL command-line utility to:
      - build and maintain Geographic Object Libraries (GeoDesk's compact database format for OpenStreetMap features)
      - perform GOQL queries and export the results in a variety of formats.
    '';
    homepage = "https://docs.geodesk.com/gol";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.starsep ];
    platforms = platforms.all;
  };
}
