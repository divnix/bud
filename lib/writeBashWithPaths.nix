{ pkgs, lib }:
paths: name: script:
pkgs.writers.writeBash name ''
  export PATH="${lib.makeBinPath paths}"
  source ${script}
''
