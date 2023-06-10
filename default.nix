{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.guile_3_0
    pkgs.guile-gcrypt
    pkgs.guile-json
  ];

  shellHook = ''
    transform() {
        for path in $(echo $GUILE_LOAD_PATH | sed 's/:/\n/g'| sort | uniq); do
            if [ -d "$path/3.0" ]; then
                echo $path
            else
                echo $path/$(ls -1 $path | tail -n 1)
            fi
        done
    }

    export GUILE_LOAD_PATH=$(transform | tr '\n' : | sed 's/:$//')
  '';
}
