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
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fennel-tools.overlays.default ];
        };
      in
      {
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
              # NOTE: Cannot handle cljlib. Skip this for now.
              # pkgs.fennel-ls
            ] ++ (with fennel.lua.pkgs; [
              readline
            ]);
            FENNEL_PATH = "./src/?.fnl;./src/?/init.fnl";
            FENNEL_MACRO_PATH = "./src/?.fnl;./src/?/init-macros.fnl";
          };
      });
}
