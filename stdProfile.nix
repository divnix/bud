{ stdProfilePath, pkgs, lib, flkUtils, ... }: {
  flk.cmds = with pkgs; {

    # Onboarding
    up = {
      writer = flkUtils.writeBashWithPaths [ nixos-install-tools ];
      synopsis = "up";
      help = "Generate $FLKROOT/hosts/\${HOST//\./\/}/default.nix";
      script = ./scripts/onboarding-up.bash;
    };

    # Utils
    update = {
      writer = flkUtils.writeBashWithPaths [ nixUnstable ];
      synopsis = "update [INPUT]";
      help = "Update and commit $FLKROOT/flake.lock file or specific input";
      script = ./scripts/utils-update.bash;
    };
    repl = {
      writer = flkUtils.writeBashWithPaths [ nixUnstable gnused ];
      synopsis = "repl [FLAKE]";
      help = "Enter a repl with the flake's outputs";
      script = (import ./scripts/utils-repl pkgs).outPath;
    };
    ssh-show = {
      writer = flkUtils.writeBashWithPaths [ openssh ];
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
      writer = flkUtils.writeBashWithPaths [ nixUnstable ];
      synopsis = "home [switch] HOST USER";
      help = "Home-manager config of USER from HOST";
      script = ./scripts/hm-home.bash;
    };

    # Hosts
    build = {
      writer = flkUtils.writeBashWithPaths [ nixUnstable ];
      synopsis = "build HOST BUILD";
      help = "Build a variant of your configuration from system.build";
      script = ./scripts/hosts-build.bash;
    };
    vm = {
      writer = flkUtils.writeBashWithPaths [ nixUnstable ];
      synopsis = "vm HOST";
      help = "Generate & run a one-shot vm for HOST";
      script = ./scripts/hosts-vm.bash;
    };
    install = {
      writer = flkUtils.writeBashWithPaths [ nixos-install-tools ];
      synopsis = "install HOST [ARGS]";
      help = "Shortcut for nixos-install";
      script = ./scripts/hosts-install.bash;
    };
    rebuild = {
      writer = flkUtils.writeBashWithPaths [ nixos-rebuild ];
      synopsis = "rebuild HOST (switch|boot|test)";
      help = "Shortcut for nixos-rebuild";
      script = ./scripts/hosts-rebuild.bash;
    };

  };
}
