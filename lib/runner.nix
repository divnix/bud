{ lib, pkgs, ... }:
paths: preScript: script:
let
  isPython = script: lib.hasSuffix ".py" script;
  isHaskell = script: lib.hasSuffix ".hs" script;
  isBashOrsh = script: lib.hasSuffix ".bash" script || lib.hasSuffix ".sh" script;

  run-bash = pkgs.writers.writeBash "${builtins.baseNameOf script}" ''
    export PATH="${lib.makeBinPath paths}"
    ${preScript}
    source ${script}
  '';

  run-python = pkgs.writers.writePython3 "${builtins.baseNameOf script}"
    {
      libraries = paths;
    } ''
    ${preScript}
    ${pkgs.lib.fileContents script}
  '';

  run-haskell = pkgs.writers.writeHaskell "${builtins.baseNameOf script}"
    {
      libraries = paths;
    } ''
    ${preScript}
    ${pkgs.lib.fileContents script}
  '';

  runner = if (isPython script) then run-python else
  if (isBashOrsh script) then run-bash else if (isHaskell script) then
    run-haskell else run-bash;
in
runner
