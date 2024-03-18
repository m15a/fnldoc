final: prev:

let
  inherit (prev.lib)
    optionalAttrs
    cartesianProductOfSets;

  mkCITest = { fennelVariant, luaVariant }:
  let
    fennelName =
      if fennelVariant == "stable"
      then "fennel-${luaVariant}"
      else "fennel-${fennelVariant}-${luaVariant}";
  in {
    name = "ci-check-${fennelName}";
    value = (final.fnldoc.override {
      fennel = final.${fennelName};
    }).overrideAttrs (old: {
      pname = old.pname + "-ci-check-${fennelName}";
      dontBuild = true;
      doCheck = true;
      checkTarget = "test";
      installPhase = "touch $out";
      dontFixup = true;
    });
  };

  buildPackageSet = { builder, args }:
    builtins.listToAttrs (map builder args);
in

{
  ci-doc = final.mkShell {
    buildInputs = [
      final.gnumake
      final.fnldoc
    ];
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
