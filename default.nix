{ system ? builtins.currentSystem
, inputs ? import ./ufr-polyfills/flake.lock.nix ./.

  # alternative 1 --------------------------------------------------

, pkgs ? import inputs.nixpkgs {
    inherit system;
    overlays = inputs.nixpkgs.lib.optionals
      ((inputs ? self) && (inputs.self ? overlays))
      (builtins.attrValues inputs.self.overlays)
    ;
    config = { };
  }

  # function config ------------------------------------------------

, budModules ? pkgs.lib.optionals
    ((inputs ? self) && (inputs.self ? budModules))
    (builtins.attrValues inputs.self.budModules)

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
  name = "bud";
  description = "Your highly customizable system ctl";

  budModule = import ./modules;
  stdProfile = import ./lib/stdProfile.nix;

  pkgsModule = { config, lib, ... }: {
    config = {
      _module.args.name = name;
      _module.args.baseModules = [ budModule ];
      _module.args.pkgs = lib.mkDefault pkgs;
      _module.args.hostConfig = hostConfig;
      _module.args.editableFlakeRoot = editableFlakeRoot;
    };
  };

  budUtilsModule = { pkgs, lib, ... }: {
    config = {
      _module.args.budUtils = {
        writeBashWithPaths = import ./lib/writeBashWithPaths.nix {
          inherit pkgs lib;
        };
      };
    };
  };

  evaled = lib.evalModules {
    modules = [ pkgsModule budUtilsModule budModule stdProfile ] ++ budModules;
  };

in
evaled.config.bud.cmd // {
  meta = { inherit description; };
}
