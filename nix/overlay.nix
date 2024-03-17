{ shortRev ? null }:

final: prev:

let
  inherit (prev.lib)
    strings readFile optionalAttrs cartesianProductOfSets;

  packageVersions = strings.fromJSON (readFile ./versions.json);

  mkCITest = { fennelVariant, luaVariant }:
  let
    fennelName =
      if fennelVariant == "stable"
      then "fennel-${luaVariant}"
      else "fennel-${fennelVariant}-${luaVariant}";
  in {
    name = "ci-check-fnldoc-${fennelName}";
    value = (final.fnldoc.override {
      fennel = final.${fennelName};
    }).overrideAttrs (_: {
      doCheck = true;
      checkTarget = "test";
    });
  };

  buildPackageSet = { builder, args }:
    builtins.listToAttrs (map builder args);
in

{
  fnldoc = final.callPackage ./package.nix rec {
    version = packageVersions.fnldoc;
    inherit shortRev;
    src = ../.;
    fennel = final.fennel-unstable-luajit;
  };
} // (buildPackageSet {
    builder = mkCITest;
    args = cartesianProductOfSets {
      fennelVariant = [
        "stable"
        "unstable"
      ];
      luaVariant = [
        "lua5_1"
        "lua5_2"
        "lua5_3"
        "lua5_4"
        "luajit"
      ];
    };
  })
