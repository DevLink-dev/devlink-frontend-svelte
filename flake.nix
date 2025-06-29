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
      default = terralux-frontend;
      terralux-frontend = pkgs.buildNpmPackage {
        name = "devlink";
        src = ./.;

        npmDepsHash = "sha256-kUJa63D5A5gJhiGw5JuowIF1vXfB2Aaaxsmpi2z8E0s=";

        # runs `npm run build` by default

        installPhase = ''
          mkdir -p $out/bin/src
          cp -r build/* $out/bin/src
          makeWrapper "${pkgs.nodejs}/bin/node" "$out/bin/terralux-frontend" \
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
