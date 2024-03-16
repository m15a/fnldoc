{ version
, shortRev ? null
, src
, fennel
, stdenv
, lib
}:

let
  version' = version;
in

stdenv.mkDerivation rec {
  pname = "fnldoc";
  version = version' + lib.optionalString (shortRev != null) "-${shortRev}";
  inherit src;

  nativeBuildInputs = [
    fennel.lua
    fennel
  ];

  makeFlags = with lib; [
    "VERSION=${version}"
    "PREFIX=$(out)"
  ];

  # doCheck = true;
  # checkTarget = "test";

  postBuild = ''
    patchShebangs .
  '';

  meta = with lib; {
    description = "Tool for automatic documentation generation and validation for the Fennel language.";
    homepage = "https://sr.ht/~m15a/fnldoc";
    license = licenses.mit;
    mainProgram = pname;
  };
}
