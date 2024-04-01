{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fennel-tools = {
      url = "github:m15a/flake-fennel-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fennel-tools, ... }:
    ({
      overlays.default = import ./nix/overlay.nix {
        shortRev =
          self.shortRev or self.dirtyShortRev or self.lastModified or "unknown";
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            fennel-tools.overlays.default
            self.overlays.default
            (import ./nix/ci.nix)
          ];
        };
      in rec {
        packages = rec {
          inherit (pkgs) fnldoc;
          default = fnldoc;
        };

        apps = with flake-utils.lib;
          builtins.mapAttrs (name: pkg:
            mkApp {
              drv = pkg;
              name = pkg.meta.mainProgram or pkg.pname;
            }) packages;

        checks = packages;

        devShells = {
          inherit (pkgs)
            ci-doc

            # TODO: macro compilation fails:
            #ci-check-fennel-lua5_1 ci-check-fennel-unstable-lua5_1
            # TODO: some tests fail:
            #ci-check-fennel-lua5_2 ci-check-fennel-unstable-lua5_2
            ci-check-fennel-lua5_3 ci-check-fennel-unstable-lua5_3
            ci-check-fennel-lua5_4 ci-check-fennel-unstable-lua5_4
            ci-check-fennel-luajit ci-check-fennel-unstable-luajit;

          default = let fennel = pkgs.fennel-unstable-luajit;
          in pkgs.mkShell {
            packages = [
              fennel
              fennel.lua
              pkgs.fnlfmt-unstable
              pkgs.fennel-ls-unstable
              pkgs.nixfmt
            ] ++ (with fennel.lua.pkgs; [ readline ]);
            FENNEL_PATH = "./src/?.fnl;./src/?/init.fnl";
            FENNEL_MACRO_PATH = "./src/?.fnl;./src/?/init-macros.fnl";
          };
        };
      }));
}
