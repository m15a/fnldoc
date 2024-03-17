{ shortRev ? null }:

final: prev:

let
  inherit (prev.lib)
    strings
    readFile
    optionalString;

  packageVersions = strings.fromJSON (readFile ./versions.json);
in

{
  fnldoc = final.callPackage ./package.nix rec {
    version =
      packageVersions.fnldoc +
      optionalString (shortRev != null) "-${shortRev}";
    src = ../.;
    fennel = final.fennel-unstable-luajit;
  };
}
