{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.guile_2_2
    pkgs.guile-gcrypt
    pkgs.guile-json
  ];
  shellHook = ''
    echo $GUILE_LOAD_PATH | sed 's/:/\n/g'
  '';
}
