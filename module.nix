{ name, config, lib, pkgs, hostConfig, editableFlakeRoot, ... }:
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

  host = let
    partitionString = sep: s:
      builtins.filter (v: builtins.isString v) (builtins.split "${sep}" s);
    reversePartition = s: lib.reverseList (partitionString "\\." s);
    rebake = l: builtins.concatStringsSep "." l;
  in
    if (hostConfig != null && hostConfig.networking.domain != null) then
      rebake (reversePartition hostConfig.networking.domain + [ hostConfig.networking.hostName ])
    else if hostConfig != null then
      hostConfig.networking.hostName
    # fall back to reverse dns from hostname --fqdn command
    else "$(IFS='.'; parts=($(hostname --fqdn)); IFS=' '; HOST=$(for (( idx=\${#parts[@]}-1 ; idx>=0 ; idx-- )) ; do printf \"\${parts[idx]}.\"; done); echo \${HOST:: -1})"
  ;

  flkRoot =
    if editableFlakeRoot != null
    then editableFlakeRoot
    else "$DEVSHELL_ROOT"
  ;


  flkCmd = pkgs.writeShellScriptBin name ''

    shopt -s extglob

    FLKROOT="${flkRoot}" # writable
    HOST="${host}"
    USER="$(whoami)"

    # needs a FLKROOT
    [[ -d "$FLKROOT" ]] ||
      {
        echo "This script must be run either from the flake's devshell or its root path must be specified" >&2
        exit 1
      }

    # FLKROOT must be writable (no store path)
    [[ -w "$FLKROOT" ]] ||
      {
        echo "You canot use the flake's store path for reference."
             "This script requires a pointer to the writable flake root." >&2
        exit 1
      }


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
