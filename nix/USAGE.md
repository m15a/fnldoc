# Nix usage

If you are a Nix user, add Fnldoc overlay to your project flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fnldoc.url = "sourcehut:~m15a/fnldoc/main";
    ...
  };
  ...
  outputs = inputs @ { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ...
            inputs.fnldoc.overlays.default
          ];
        };
      in
      {
        devShells.default = {
          buildInputs = [
            ...
            pkgs.fnldoc
          ];
        };
      });
}
```

You can also try Fnldoc quickly:

```console
$ nix run sourcehut:~m15a/fnldoc -- --fnldoc-version
1.1.0-dev-68bbdc1
```

<!-- vim: set tw=72 spell: -->
