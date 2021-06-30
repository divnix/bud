{ name, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flk;
  entryOptions = {
    enable = mkEnableOption "cmd" // { default = true; };

    script = mkOption {
      type = types.path;
      description = ''
        Script to run.
        Scripts are required to:
          - declare $synopsis, $help & $description
          - declare cmd () function
      '';
    };

    deps = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        A list of other commands that this one should be cuaranteed to be placed after.
      '';
    };
  };

  addUsage =
    mapAttrs (k: v: builtins.removeAttrs v [ "script" "enable" ] // {
      text = ''
        "$(source ${v.script}; echo $synopsis;)" \
        "$(source ${v.script}; echo $help;)" \'';
    });

  addCase =
    mapAttrs (k: v: builtins.removeAttrs v [ "script" "enable" ] // {
      text = ''
        # ${k} subcommand
        "${k}")
          shift 1;
          source ${v.script}
          mkcmd "$@"
          ;;

      '';
    });

  flkCmd = pkgs.writeShellScriptBin name ''

    [[ -d "$DEVSHELL_ROOT" ]] ||
      {
        echo "This script must be run from devos's devshell" >&2
        exit 1
      }

    shopt -s extglob

    HOSTNAME="$(hostname)"
    FLKROOT="$DEVSHELL_ROOT"


    # Contracts from script: $synopsis, $help, $description & `cmd` function
    mkcmd () {
      case "$1" in
        "-h"|"help"|"--help")
          printf "%b\n" \
                 "" \
                 "\e[4mUsage\e[0m: $synopsis   $help\n" \
                 "\e[4mDescription\e[0m: $description"
          ;;
        *)
          cmd "$@" # contract from script
          ;;
      esac
    }

    usage () {
    printf "%b\n" \
      "" \
      "\e[4mUsage\e[0m: $(basename $0) COMMAND [ARGS]\n" \
      "\e[4mCommands\e[0m:"

    # Contracts from script: $synopsis, $help
    printf "  %-30s %s\n\n" \
    ${textClosureMap id (addUsage cfg.cmds) (attrNames cfg.cmds)}

    }

    case "$1" in
    ""|"-h"|"help"|"--help")
      usage
      ;;

    ${textClosureMap id (addCase cfg.cmds) (attrNames cfg.cmds)}
    esac
  '';
in
{
  options.flk = {
    cmds = mkOption {
      type = types.attrsOf (types.nullOr (types.submodule { options = entryOptions; }));
      default = { };
      internal = true;
      apply = as: filterAttrs (_: v: v.enable == true) as;
      description = ''
        A list of sub commands appended to the `flk` case switch statement.
      '';
    };
    cmd = mkOption {
      internal = true;
      type = types.package;
      description = ''
        This package contains the fully resolved `flk` script.
      '';
    };
  };

  config.flk = {
    cmd = flkCmd;
  };
}
