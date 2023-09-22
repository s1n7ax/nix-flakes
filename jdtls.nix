{
  stdenv,
  fetchurl,
  jdk19_headless,
  python3,
  ...
}: stdenv.mkDerivation {
  pname = "jdtls";
  version = "1.28.0";

  src = fetchurl {
    url = "https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-1.28.0-202309221544.tar.gz";
    sha256 = "zr17RSPJz0LiUxzIAZ+fmvPnPK12K6pe3ZP/Hj8+7CY=";
  };

  buildInputs = [ jdk19_headless ];

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

    echo 'Starting JDTLS'

    # setting paths
    PATH="${jdk19_headless}/bin:${python3}/bin:$PATH"
    JAVA_HOME="${jdk19_headless}"

    $out/share/bin/jdtls
    EOL
  '';

  fixupPhase = ''
    ls -l 
    chmod u+x $out/bin/jdtls
  '';
}
