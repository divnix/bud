{
  description = "Bud - a highly composable system ctl command";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://nrdxp.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    devshell.url = "github:numtide/devshell";
    beautysh.url = "github:lovesegfault/beautysh";
  };

  outputs = { self, nixpkgs, devshell, beautysh, ... }:
    let

      # Unofficial Flakes Roadmap - Polyfills
      # .. see: https://demo.hedgedoc.org/s/_W6Ve03GK#
      # .. also: <repo-root>/ufr-polyfills

      # Super Stupid Flakes / System As an Input - Style:
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      ufrContract = import ./ufr-polyfills/ufrContract.nix;

      # Dependency Groups - Style
      budInputs = { inherit self nixpkgs; };

      # repind this flake's functor to new self as part of the inputs
      # this helps to completely avoid invoking flake.lock.nix.
      # In a flake-only scenario, flake.lock.nix would disregard
      # inputs follows configurations.
      rebind = src: inpt: _: rebound: args:
        let
          inputs = inpt // { self = rebound; };
        in
        import src ({ inherit inputs; } // args);

      # Dependency Groups - Style
      devShellInputs = { inherit nixpkgs devshell beautysh; };

      # .. we hope you like this style.
      # .. it's adopted by a growing number of projects.
      # Please consider adopting it if you want to help to improve flakes.

    in
    {
      lib.writeBashWithPaths = import ./lib/writeBashWithPaths.nix;
      nixosModules.bud = import ./modules/nixosModule.nix self;
      devshellModules.bud = import ./modules/devshellModule.nix self;

      defaultPackage = ufrContract supportedSystems ./. budInputs;

      # The flake's functor ...
      # ... knows how to consume the self.overlays it's currently bound to
      overlays = { };

      # ... knows how to consume self.budModules it's currently bound to
      budModules = { };

      # usage: inputs.bud newSelf { ... };
      __functor = rebind ./. budInputs;

      # bud-local use
      devShell = ufrContract supportedSystems ./shell.nix devShellInputs;

    };
}
