{
  description = "Flk - a highly composable system ctl command";

  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: let

    # Unofficial Flakes Roadmap - Polyfills
    # .. see: https://demo.hedgedoc.org/s/_W6Ve03GK#
    # .. also: <repo-root>/ufr-polyfills

    # Super Stupid Flakes / System As an Input - Style:
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin"];
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

    # .. we hope you like this style.
    # .. it's adopted by a growing number of projects.
    # Please consider adopting it if you want to help to improve flakes.

  in
  {

    defaultPackage = ufrContract supportedSystems ./. flkInputs;

    # The flake's functor ...
    # ... knows how to consume the self.overlays it's currently bound to
    overlays = {
    };

    # ... knows how to consume self.flkModules it's currently bound to
    flkModules = {
      disable-repl = { flk.cmds.repl.enable = false; }; # it's not yet working
    };

    # usage: inputs.flk newSelf { ... };
    __functor = rebind ./. flkInputs;

  };
}
