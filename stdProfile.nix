{ stdProfilePath, pkgs, lib, budUtils, ... }:
let
  # pkgs.nixos-install-tools does not build on darwin
  installPkgs = (import "${toString pkgs.path}/nixos/lib/eval-config.nix" {
    inherit (pkgs) system;
    modules = [ ];
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
    repl = {
      writer = budUtils.writeBashWithPaths [ nixUnstable gnused git mercurial ];
      synopsis = "repl [FLAKE]";
      help = "Enter a repl with the flake's outputs";
      script = (import ./scripts/utils-repl pkgs).outPath;
    };
    ssh-show = {
      writer = budUtils.writeBashWithPaths [ openssh ];
      synopsis = "ssh-show HOST USER | USER@HOSTNAME";
      help = "Show target host's SSH ed25519 key";
      description = ''
        Use this script to quickly determine the target host
        key for which to encrypt an agenix secret.
      '';
      script = ./scripts/utils-ssh-show.bash;
    };

    # Deploy

    yeet = {
      writer = budUtils.writeBashWithPaths [ nixUnstable git mercureial coreutils openssh deploy-rs.deploy-rs ];
      synopsis = "yeet [ ... ]";
      help = "Yeet profile configurations at hosts via deploy-rs";
      script = ./scripts/yeet.bash;
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

  };
}
