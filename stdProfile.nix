{ stdProfilePath, pkgs, lib, budUtils, ... }:
let
  # pkgs.nixos-install-tools does not build on darwin
  installPkgs = (import "${toString pkgs.path}/nixos/lib/eval-config.nix" {
    inherit (pkgs) system;
    modules = [ { nix.package = pkgs.nixUnstable; } ];
  }).config.system.build;
in
{
  bud.cmds = with pkgs; {

    # Onboarding
    up = {
      writer = budUtils.writeBashWithPaths [ installPkgs.nixos-generate-config git mercurial coreutils ];
      synopsis = "up";
      help = "Generate $FLAKEROOT/hosts/\${HOST//\./\/}/default.nix";
      script = ./scripts/onboarding-up.bash;
    };

    # Utils
    update = {
      writer = budUtils.writeBashWithPaths [ nixUnstable git mercurial ];
      synopsis = "update [INPUT]";
      help = "Update and commit $FLAKEROOT/flake.lock file or specific input";
      script = ./scripts/utils-update.bash;
    };
    burn = {
      writer = budUtils.writeBashWithPaths [ nixUnstable git mercurial coreutils gawk util-linux fzf pv ];
      synopsis = "burn";
      help = "Burn an ISO on a removable device that you interactively choose (build the iso first)";
      script = ./scripts/burn.bash;
    };
    repl = {
      writer = budUtils.writeBashWithPaths [ nixUnstable gnused git mercurial coreutils ];
      synopsis = "repl [FLAKE]";
      help = "Enter a repl with the flake's outputs";
      script = (import ./scripts/utils-repl pkgs).outPath;
    };
    ssh-show = {
      writer = budUtils.writeBashWithPaths [ openssh coreutils ];
      synopsis = "ssh-show HOST USER | USER@HOSTNAME";
      help = "Show target host's SSH ed25519 key";
      description = ''
        Use this script to quickly determine the target host
        key for which to encrypt an agenix secret.
      '';
      script = ./scripts/utils-ssh-show.bash;
    };

    # Home-Manager
    home = {
      writer = budUtils.writeBashWithPaths [ nixUnstable git mercurial coreutils ];
      synopsis = "home [switch] (user@fqdn | USER HOST | USER)";
      help = "Home-manager config of USER from HOST or host-less portable USER for current architecture";
      script = ./scripts/hm-home.bash;
    };

    # Hosts
    build = {
      writer = budUtils.writeBashWithPaths [ nixUnstable git mercurial coreutils ];
      synopsis = "build HOST BUILD";
      help = "Build a variant of your configuration from system.build";
      script = ./scripts/hosts-build.bash;
    };
    vm = {
      writer = budUtils.writeBashWithPaths [ nixUnstable git mercurial coreutils ];
      synopsis = "vm HOST";
      help = "Generate & run a one-shot vm for HOST";
      script = ./scripts/hosts-vm.bash;
    };
    install = {
      writer = budUtils.writeBashWithPaths [ installPkgs.nixos-install git mercurial coreutils ];
      synopsis = "install HOST [ARGS]";
      help = "Shortcut for nixos-install";
      script = ./scripts/hosts-install.bash;
    };
    rebuild = {
      writer = budUtils.writeBashWithPaths [ installPkgs.nixos-rebuild git mercurial coreutils ];
      synopsis = "rebuild HOST (switch|boot|test)";
      help = "Shortcut for nixos-rebuild";
      script = ./scripts/hosts-rebuild.bash;
    };

  };
}
