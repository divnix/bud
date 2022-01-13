{ lib, pkgs, ... }:
paths: name: script:
let
  isPython = script: lib.hasSuffix ".py" script;
  isBashOrsh = script: lib.hasSuffix ".bash" script || lib.hasSuffix ".sh" script;

  run-bash = pkgs.writers.writeBash "${name}-bash" ''
    export PATH="${lib.makeBinPath paths}"
    source ${script}
  '';

  run-python = pkgs.writers.writePython3 "${name}-python"
    {
      libraries = paths;
    } ''
    ${pkgs.lib.fileContents script}
  '';

  runner = if (isPython script) then run-python else
  if (isBashOrsh script) then run-bash else
  run-bash;
in
runner
