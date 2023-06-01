{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };
  outputs = inputs:
    let
      forAllSystems = f:
        inputs.nixpkgs.lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed
          (system: f inputs.nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            bazel_6
            bazel-buildtools
            pre-commit
            cacert
          ];
        };
      });
    };
}
