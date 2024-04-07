final: prev:

let
  inherit (prev.lib) optionalAttrs cartesianProductOfSets;

  buildPackageSet = { builder, args }: builtins.listToAttrs (map builder args);

  builder =
    { fennelVariant, luaVariant }:
    let
      fennelName =
        if fennelVariant == "stable" then
          "fennel-${luaVariant}"
        else
          "fennel-${fennelVariant}-${luaVariant}";
    in
    {
      name = "ci-check-${fennelName}";
      value = final.callPackage mkCICheckShell { fennel = final.${fennelName}; };
    };

  mkCICheckShell =
    { mkShell, fennel }:
    mkShell {
      packages = [ fennel ];
      FENNEL_PATH = "./src/?.fnl;./src/?/init.fnl";
      FENNEL_MACRO_PATH = "./src/?.fnl;./src/?/init-macros.fnl";
    };
in
{
  ci-doc = final.mkShell {
    packages =
      let
        fennel = final.fennel-luajit;
      in
      [
        final.git
        fennel
        fennel.lua
      ];
    FENNEL_PATH = "./src/?.fnl;./src/?/init.fnl";
    FENNEL_MACRO_PATH = "./src/?.fnl;./src/?/init-macros.fnl";
  };
}
// buildPackageSet {
  inherit builder;
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
}
