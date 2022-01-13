{ name, config, lib, pkgs, hostConfig, editableFlakeRoot, ... }:
with lib;
let
  cfg = config.bud;
  entryOptions = {
    enable = mkEnableOption "cmd" // { default = true; };

    synopsis = mkOption {
      type = types.str;
      description = ''
        Synopsis.
      '';
    };
    help = mkOption {
      type = types.str;
      description = ''
        Short help.
      '';
    };
    description = mkOption {
      type = types.str;
      default = "";
      description = ''
        Longer descriptions.
      '';
    };

    writer = mkOption {
      type = types.functionTo (types.functionTo types.package);
      description = ''
        Script to run.
      '';
    };

    script = mkOption {
      type = types.path;
      description = ''
        Script to run.
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
    mapAttrs (k: v: builtins.removeAttrs v [ "script" "enable" "synopsis" "help" "description" ] // {
      text = ''
        "${v.synopsis}" "${v.help}" \'';
    });

  addCase =
    mapAttrs (k: v: builtins.removeAttrs v [ "script" "enable" "synopsis" "help" "description" ] // {
      text =
        let
          script' = v.writer (builtins.baseNameOf v.script) v.script;
        in
        ''
          # ${k} subcommand
          "${k}")
            shift 1;
            mkcmd "${v.synopsis}" "${v.help}" "${v.description}" "${script'}" "$@"
            ;;

        '';
    });

  arch = pkgs.system;

  host =
    let
      partitionString = sep: s:
        builtins.filter (v: builtins.isString v) (builtins.split "${sep}" s);
      reversePartition = s: lib.reverseList (partitionString "\\." s);
      rebake = l: builtins.concatStringsSep "." l;
    in
    if (hostConfig != null && hostConfig.networking.domain != null) then
      rebake (reversePartition hostConfig.networking.domain ++ [ hostConfig.networking.hostName ])
    else if hostConfig != null then
      hostConfig.networking.hostName
    # fall back to reverse dns from hostname --fqdn command
    else "$(IFS='.'; parts=($(hostname --fqdn)); IFS=' '; HOST=$(for (( idx=\${#parts[@]}-1 ; idx>=0 ; idx-- )) ; do printf \"\${parts[idx]}.\"; done); echo \${HOST:: -1})"
  ;

  flakeRoot =
    if editableFlakeRoot != null
    then editableFlakeRoot
    else "$PRJ_ROOT"
  ;


  budCmd = pkgs.writeShellScriptBin name ''

    export PATH="${makeBinPath [ pkgs.coreutils pkgs.hostname ]}"

    shopt -s extglob

    FLAKEROOT="${flakeRoot}" # writable
    HOST="${host}"
    USER="$(logname)"
    ARCH="${arch}"

    # mocks: for testing onlye
    FLAKEROOT="''${TEST_FLAKEROOT:-$FLAKEROOT}"
    HOST="''${TEST_HOST:-$HOST}"
    USER="''${TEST_USER:-$USER}"
    ARCH="''${TEST_ARCH:-$ARCH}"

    # needs a FLAKEROOT
    [[ -d "$FLAKEROOT" ]] ||
      {
        echo "This script must be run either from the flake's devshell or its root path must be specified" >&2
        exit 1
      }

    # FLAKEROOT must be writable (no store path)
    [[ -w "$FLAKEROOT" ]] ||
      {
        echo "You canot use the flake's store path for reference."
             "This script requires a pointer to the writable flake root." >&2
        exit 1
      }


    mkcmd () {
      synopsis=$1
      help=$2
      description=$3
      script=$4
      shift 4;
      case "$1" in
        "-h"|"help"|"--help")
          printf "%b\n" \
                 "" \
                 "\e[4mUsage\e[0m: $synopsis   $help\n" \
                 "\e[4mDescription\e[0m:\n$description"
          ;;
        *)
          FLAKEROOT="$FLAKEROOT" HOST="$HOST" USER="$USER" ARCH="$ARCH" exec $script "$@"
          ;;
      esac
    }

    usage () {
    printf "%b\n" \
      "" \
      "\e[4mUsage\e[0m: $(basename $0) COMMAND [ARGS]\n" \
      "\e[4mCommands\e[0m:"

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
  options.bud = {
    cmds = mkOption {
      type = types.attrsOf (types.nullOr (types.submodule { options = entryOptions; }));
      default = { };
      internal = true;
      apply = as: filterAttrs (_: v: v.enable == true) as;
      description = ''
        A list of sub commands appended to the `bud` case switch statement.
      '';
    };
    cmd = mkOption {
      internal = true;
      type = types.package;
      description = ''
        This package contains the fully resolved `bud` script.
      '';
    };
  };

  config.bud = {
    cmd = budCmd;
  };
}
