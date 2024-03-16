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
      overlays.default = import ./nix/overlay.nix;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            fennel-tools.overlays.default
            self.overlays.default
          ];
        };
      in
      rec {
        packages = rec {
          inherit (pkgs)
            fnldoc-unstable;
          default = fnldoc-unstable;
        };

        apps = with flake-utils.lib;
          builtins.mapAttrs
            (name: _: mkApp { drv = self.packages.${system}.${name}; })
            packages;

        checks = packages;

        devShells.default =
          let
            fennel = pkgs.fennel-unstable-luajit;
          in
          pkgs.mkShell {
            buildInputs = [
              fennel
              fennel.lua
              pkgs.gnumake
              pkgs.fnlfmt-unstable
              pkgs.fennel-ls-unstable
            ] ++ (with fennel.lua.pkgs; [
              readline
            ]);
            FENNEL_PATH = "./src/?.fnl;./src/?/init.fnl";
            FENNEL_MACRO_PATH = "./src/?.fnl;./src/?/init-macros.fnl";
          };
      }));
}
