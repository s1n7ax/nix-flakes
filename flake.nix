{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages."${system}" = rec {
        jdtls = pkgs.callPackage ./jdtls.nix {};
        devcontainer = pkgs.callPackage ./devcontainer/devcontainer.nix {};
        default = devcontainer;
      };
    };
}
