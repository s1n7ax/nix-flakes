{ lib, mkYarnPackage, fetchFromGitHub, nodejs_18, fetchYarnDeps, makeWrapper }:
mkYarnPackage rec {
  pname = "devcontainer";
  version = "0.52.0";

  src = fetchFromGitHub {
    owner = "devcontainers";
    repo = "cli";
    rev = "v${version}";
    sha256 = "sha256-h1xTXMh0ZDeDfkAS9TDq12mG9dZaVOLn78R80dRlPPg=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    sha256 = "Ayp75uL7qV4/u1IVwuJmEEfYMLf13sIWlw3mQfAYNIY=";
  };

  packageJSON = ./package.json;

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild

    # without home, tasks are passing but they does not do what it supposed to
    export HOME=$(mktemp -d)

    rm -rf deps/@devcontainers/cli/node_modules
    cp -r node_modules deps/@devcontainers/cli/node_modules

    yarn run --offline package

    cp deps/@devcontainers/cli/devcontainers-cli-${version}.tgz .

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    tar xf devcontainers-cli-${version}.tgz
    cp -r package/* $out

    cat > $out/bin/devcontainer <<EOL
    #!/usr/bin/env bash
    node --version
    node "$out/devcontainer.js" "\$@"
    EOL
  '';

  fixupPhase = ''
    chmod +x "$out/bin/devcontainer"

    wrapProgram $out/bin/devcontainer \
      --prefix PATH : ${lib.makeBinPath [ nodejs_18 ]}
  '';

  doDist = false;

  meta = with lib; {
    mainProgram = "devcontainer";
    description = "Development inside containers using devcontainer";
    homepage = "https://github.com/devcontainers/cli";
    license = licenses.mit;
    hangelog =
      "https://github.com/devcontainers/cli/blob/${src.rev}/CHANGELOG.md";
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ s1n7ax ];
  };
}
