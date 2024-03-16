final: prev:

let
  inherit (prev.lib) strings readFile;

  packageVersions = strings.fromJSON (readFile ./versions.json);
in

{
  fnldoc-unstable = final.callPackage ./package.nix rec {
    version = packageVersions.fnldoc-unstable;
    src = ../.;
    fennel = final.fennel-unstable-luajit;
  };
}
