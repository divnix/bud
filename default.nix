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

# pass the host's config for inferring the reverse dns fqdn of this host
# so that this script can accessor the _current_ host identifier in
# self.nixosConfigurations.<identifier>
, hostConfig ? null

# pass a string to the path where you hold a (writable) local copy of the flake repo
# so that this script can execute operations on that flake, such as updates, etc.
, editableFlakeRoot ? null

}:
let

  lib = pkgs.lib;
  name = "flk";
  description = "Your highly customizable system ctl";

  flkModule = import ./module.nix;
  stdProfile = import ./stdProfile.nix;

  pkgsModule = { config, ... }: {
    config = {
      _module.args.name = name;
      _module.args.baseModules = [ flkModule ];
      _module.args.pkgs = lib.mkDefault pkgs;
      _module.args.hostConfig = hostConfig;
      _module.args.editableFlakeRoot = editableFlakeRoot;
    };
  };

  evaled = lib.evalModules {
    modules = [ pkgsModule flkModule stdProfile] ++ flkModules;
  };

in evaled.config.flk.cmd // {
  meta = { inherit description; };
}
