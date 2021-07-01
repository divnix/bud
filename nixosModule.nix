# the flk function that still needs to be instantiated
flk:

{ config, pkgs, lib, ... }:
let
 cfg = config.flk;
in
with lib; {
  options.flk = {
    enable = mkEnableOption "enable flk sysctl tool";
    localFlakeClone = mkOption {
      type = types.string;
      description = ''
        A string reference to the local (editable) copy
        of your system flake. This is used as reference
        so that the scripts can do work on your flake,
        such as for example updating inputs.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (flk { inherit pkgs; hostConfig = config; editableFlakeRoot = cfg.localFlakeClone; })
    ];
  };

}
