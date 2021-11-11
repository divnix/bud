{ pkgs, lib }:
paths: extra: script:
let
  whichScript = s: lib.hasSuffix s (builtins.baseNameOf script);
  PYTHONPATH =
    lib.concatStringsSep ":" (map
      (f:
        let
          pythonVersion = lib.elemAt
            (builtins.filter builtins.isString
              (builtins.split "-" "${f}")) 1;
        in
        "${f}/lib/${pythonVersion}/site-packages")
      paths);
in
pkgs.writers.writeBash (builtins.baseNameOf script) ''
  export PATH="${lib.makeBinPath paths}"
  export PYTHONPATH="${PYTHONPATH}"
  ${extra}

  ${lib.optionalString (whichScript "bash") ''
  source ${script}
  ''}
  ${lib.optionalString (whichScript "py") ''
  python ${script}
  ''}
''
