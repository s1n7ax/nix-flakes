{ lib
, mkYarnPackage
, fetchFromGitHub
, makeWrapper
, nodejs
, fetchYarnDeps
,
}:
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
    export HOME=$(mktemp -d)
    yarn --offline compile-prod
    runHook postBuild
  '';

  postInstall = ''
    wrapProgram "$out/bin/devcontainer" --prefix PATH : "${nodejs}/bin"
  '';

  doDist = false;

  meta = with lib; {
    mainProgram = "devcontainer";
    description = "Development inside containers using devcontainer";
    homepage = "https://github.com/devcontainers/cli";
    license = licenses.mit;
    hangelog = "https://github.com/devcontainers/cli/blob/${src.rev}/CHANGELOG.md";
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ s1n7ax ];
  };
}
