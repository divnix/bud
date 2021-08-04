# the bud function that still needs to be instantiated
bud:
{ config
, pkgs
, lib
  # we require a reference to the flake
  # in order to collect self.budModules
, self
, ...
}:
let
  reboundBud = bud self;
  cfg = config.bud;
in
with lib; {
  options.bud = {
    enable = mkEnableOption "enable bud sysctl tool";
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
      (reboundBud { inherit pkgs; hostConfig = config; editableFlakeRoot = cfg.localFlakeClone; })
    ];
  };

}
