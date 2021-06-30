{ system ? builtins.currentSystem
, inputs ? import ./ufr-polyfills/flake.lock.nix ./.

# alternative 1 --------------------------------------------------

, pkgs ? import inputs.nixpkgs {
    inherit system;
    overlays = inputs.nixpkgs.lib.optionals
      ((inputs ? self) && ( inputs.self ? overlays))
      (builtins.attrValues inputs.self.overlays)
    ;
    config = { };
  }

# function config ------------------------------------------------

, flkModules ? pkgs.lib.optionals
      ((inputs ? self) && ( inputs.self ? flkModules))
      (builtins.attrValues inputs.self.flkModules)
}:
let

  lib = pkgs.lib;
  name = "flk";
  description = "Build, deploy, and install NixOS";

  flkModule = import ./module.nix;
  stdProfile = import ./stdProfile.nix;

  pkgsModule = { config, ... }: {
    config = {
      _module.args.name = name;
      _module.args.baseModules = [ flkModule ];
      _module.args.pkgs = lib.mkDefault pkgs;
    };
  };

  evaled = lib.evalModules {
    modules = [ pkgsModule flkModule stdProfile] ++ flkModules;
  };

in evaled.config.flk.cmd // {
  meta = { inherit description; };
}
