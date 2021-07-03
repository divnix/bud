{ stdProfilePath, ... }:
{ flk.cmds = {

  # Onboarding
  up = {
    synopsis = "up";
    help = "Generate $FLKROOT/hosts/\${HOST//\./\/}/default.nix";
    script = ./scripts/onboarding-up.bash;
  };
  get = {
    synopsis = "get (core|community) [DEST]";
    help = "Copy the desired template to DEST";
    script = ./scripts/onboarding-get.bash;
  };
  
  # Utils
  update = {
    synopsis = "update [INPUT]";
    help = "Update and commit the lock file, or specific input";
    script = ./scripts/utils-update.bash;
  };
  repl = {
    synopsis = "repl FLAKE";
    help = "Enter a repl with the flake's outputs";
    script = ./scripts/utils-repl.bash;
  };
  ssh-show = {
    synopsis = "ssh-show USER@HOSTNAME";
    help = "Show target host's SSH ed25519 key";
    description = ''
      Use this script to quickly determine the target host
      key for which to encrypt an agenix secret.
    '';
    script = ./scripts/utils-ssh-show.bash;
  };

  # Home-Manager
  home = {
    synopsis = "home HOST USER [switch]";
    help = "Home-manager config of USER from HOST";
    script = ./scripts/hm-home.bash;
  };

  # Hosts
  build = {
    synopsis = "build HOST BUILD";
    help = "Build a variant of your configuration from system.build";
    script = ./scripts/hosts-build.bash;
  };
  vm = {
    synopsis = "vm HOST";
    help = "Generate a vm for HOST";
    script = ./scripts/hosts-vm.bash;
  };
  vm-run = {
    synopsis = "vm-run HOST";
    help = "run a one-shot vm for HOST";
    script = ./scripts/hosts-vm-run.bash;
  };
  install = {
    synopsis = "install HOST [ARGS]";
    help = "Shortcut for nixos-install";
    script = ./scripts/hosts-install.bash;
  };
  rebuild = {
    synopsis = "rebuild HOST (switch|boot|test)";
    help = "Shortcut for nixos-rebuild";
    script = ./scripts/hosts-rebuild.bash;
  };

}; }
