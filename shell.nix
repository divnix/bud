{ inputs, system ? builtins.currentSystem }:
let

  pkgs = import inputs.nixpkgs {
    inherit system; config = { };
    overlays = [
      (final: prev: {
        beautysh = inputs.beautysh.defaultPackage."${final.system}";
      })
    ];
  };
  devshell = import inputs.devshell { inherit pkgs system; };

  withCategory = category: attrset: attrset // { inherit category; };
  util = withCategory "utils";

  format = args: withCategory "format" {
    name = "format-bash";
    help = "formats bash scripts";
    command = ''
      set -euo pipefail
      export PATH=${pkgs.beautysh}/bin:${pkgs.findutils}/bin:$PATH
      for path in $(find $DEVSHELL_ROOT/${args} -name '*.bash')
      do
         beautysh $path
      done
    '';
  };

  test = path: host: user: name: args: withCategory "tests" {
    name = "check-${name}";
    help = "Checks ${name} subcommand";
    command = ''
      set -e

      cd $DEVSHELL_ROOT/${path}

      head=$(git rev-parse HEAD)

      trap_err() {
        local ret=$?
        echo -e \
         "\033[1m\033[31m""exit $ret: \033[0m\033[1m""command [$BASH_COMMAND] failed""\033[0m"
      }

      trap 'trap_err' ERR
      TEST_FLAKEROOT="$DEVSHELL_ROOT/${path}" TEST_HOST="${host}" TEST_USER="${user}" \
        ${pkgs.nixUnstable}/bin/nix run $DEVSHELL_ROOT -- ${name} ${args}

      git checkout -f "$head"
    '';
  };

in
devshell.mkShell {
  name = "bud";
  packages = with pkgs; [
    fd
    nixpkgs-fmt
    nixUnstable
  ];

  # tempfix: remove when merged https://github.com/numtide/devshell/pull/123
  devshell.startup.load_profiles = pkgs.lib.mkForce (pkgs.lib.noDepEntry ''
    # PATH is devshell's exorbitant privilige:
    # fence against its pollution
    _PATH=''${PATH}
    # Load installed profiles
    for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
      # If that folder doesn't exist, bash loves to return the whole glob
      [[ -f "$file" ]] && source "$file"
    done
    # Exert exorbitant privilige and leave no trace
    export PATH=''${_PATH}
    unset _PATH
  '');

  commands = [
    {
      name = "fmt";
      help = "Check Nix formatting";
      command = "nixpkgs-fmt \${@} $DEVSHELL_ROOT";
    }
    {
      name = "evalnix";
      help = "Check Nix parsing";
      command = "fd --extension nix --exec nix-instantiate --parse --quiet {} >/dev/null";
    }
    (test "e2e/devos" "NixOS" "nixos" "home" "")
    (test "e2e/devos" "NixOS" "" "build" "NixOS toplevel")
    (test "e2e/devos" "NixOS" "" "install" "-h")
    (test "e2e/devos" "NixOS" "" "rebuild" "-h")
    (test "e2e/devos" "NixOS" "" "vm" "")
    (test "e2e/devos" "NixOS.example.com" "" "up" "")
    (test "e2e/devos" "NixOS" "root" "ssh-show" "")
    (test "e2e/devos" "" "" "update" "")
    (format "scripts")
  ];
}
