{ stdenv
, fetchurl
, makeWrapper
, jdk17_headless
, python3
, lib
, ...
}: stdenv.mkDerivation {
  pname = "jdtls";
  version = "1.28.0";

  src = fetchurl {
    url = "https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-1.28.0-202309221544.tar.gz";
    sha256 = "zr17RSPJz0LiUxzIAZ+fmvPnPK12K6pe3ZP/Hj8+7CY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  unpackPhase = ''
    mkdir -p $out/share
    tar xf $src -C $out/share
  '';

  buildPhase = ''
    mkdir -p $out/bin
  '';

  installPhase = ''
    cat > $out/bin/jdtls <<EOL
    #!/usr/bin/env bash

    $out/share/bin/jdtls
    EOL
  '';

  fixupPhase = ''
    chmod u+x $out/bin/jdtls
    wrapProgram $out/bin/jdtls \
      --prefix PATH : ${lib.makeBinPath [ jdk17_headless python3 ]} \
      --prefix JAVA_HOME : "${jdk17_headless}/lib/openjdk"
  '';
}
