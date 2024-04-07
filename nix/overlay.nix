{
  shortRev ? null,
}:

final: prev:

let
  inherit (prev) lib;

  packageVersions = lib.strings.fromJSON (lib.readFile ./versions.json);
in
{
  fnldoc = final.callPackage ./package.nix rec {
    version =
      let
        version' = packageVersions.fnldoc;
      in
      if isNull (builtins.match ".*-[-.[:alnum:]]+$" version') then
        version'
      else
        version' + lib.optionalString (shortRev != null) "-${shortRev}";
    src = ../.;
    lua = final.luajit;
  };
}
