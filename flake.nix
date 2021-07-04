{
  description = "Flk - a highly composable system ctl command";

  inputs = {
    nixpkgs.url = "nixpkgs";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, devshell, ... }:
    let

      # Unofficial Flakes Roadmap - Polyfills
      # .. see: https://demo.hedgedoc.org/s/_W6Ve03GK#
      # .. also: <repo-root>/ufr-polyfills

      # Super Stupid Flakes / System As an Input - Style:
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      ufrContract = import ./ufr-polyfills/ufrContract.nix;

      # Dependency Groups - Style
      flkInputs = { inherit self nixpkgs; };

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
      devShellInputs = { inherit nixpkgs devshell; };

      # .. we hope you like this style.
      # .. it's adopted by a growing number of projects.
      # Please consider adopting it if you want to help to improve flakes.

    in
    {
      nixosModules.flk = import ./nixosModule.nix;

      defaultPackage = ufrContract supportedSystems ./. flkInputs;

      # The flake's functor ...
      # ... knows how to consume the self.overlays it's currently bound to
      overlays = { };

      # ... knows how to consume self.flkModules it's currently bound to
      flkModules = { };

      # usage: inputs.flk newSelf { ... };
      __functor = rebind ./. flkInputs;

      # flk-local use
      devShell = ufrContract supportedSystems ./shell.nix devShellInputs;

    };
}
