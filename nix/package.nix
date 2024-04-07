{
  version,
  src,
  stdenv,
  lib,
  lua,
}:

stdenv.mkDerivation rec {
  pname = "fnldoc";
  inherit version src;

  nativeBuildInputs = [ lua.pkgs.fennel ];
  buildInputs = [ lua ];

  makeFlags = [
    "VERSION=${version}"
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    description = "Tool for automatic documentation generation and validation for the Fennel language.";
    homepage = "https://sr.ht/~m15a/fnldoc";
    license = licenses.mit;
    mainProgram = pname;
  };
}
