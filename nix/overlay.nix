{ shortRev ? null }:

final: prev:

let
  inherit (prev.lib) strings readFile;

  packageVersions = strings.fromJSON (readFile ./versions.json);
in

{
  fnldoc = final.callPackage ./package.nix rec {
    version = packageVersions.fnldoc;
    inherit shortRev;
    src = ../.;
    fennel = final.fennel-unstable-luajit;
  };
}
