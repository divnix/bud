pkgs:
  pkgs.writeShellScript "repl" ''
    if [ -z "$1" ]; then
      nix repl --argstr host "$HOST" --argstr flakePath "$FLKROOT" ${./repl.nix}
    else
      nix repl --argstr host "$HOST" --argstr flakePath $(readlink -f $1 | sed 's|/flake.nix||') ${./repl.nix}
    fi
  ''
