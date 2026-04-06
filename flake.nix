{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default"; # can run on all systems
  };

  outputs = { self, nixpkgs, systems, ... }:
  let
    eachSystem = fn: nixpkgs.lib.genAttrs (import systems) (system: fn system (import nixpkgs {
      inherit system;
    }));
  in
  {
    packages = eachSystem (system: pkgs: rec {
      default = devlink-frontend-svelte;
      devlink-frontend-svelte = pkgs.buildNpmPackage {
        name = "devlink-frontend-svelte";
        src = ./.;

        npmDepsHash = "sha256-kZBP7PGScGrbqAqwOEPqqatcgMILVVzy2/qyKnajdU8=";

        # runs `npm run build` by default

        installPhase = ''
          mkdir -p $out/bin/src
          cp -r build/* $out/bin/src
          makeWrapper "${pkgs.nodejs}/bin/node" "$out/bin/devlink-frontend-svelte" \
            --add-flags "$out/bin/src" \
            --set PORT 4173
        '';
      };
    });

    devShells = eachSystem (system: pkgs: {
      default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.nodejs ];
      };
    });
  };
}
