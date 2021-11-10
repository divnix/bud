{ pkgs, lib }:
paths: extra: script:
pkgs.writers.writeBash (builtins.baseNameOf script) ''
  export PATH="${lib.makeBinPath paths}"
  ${extra}
  source ${script}
''
