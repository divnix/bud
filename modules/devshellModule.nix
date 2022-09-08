# the bud function that still needs to be instantiated
bud:
{ pkgs
  # we require a reference to the flake
  # in order to collect self.budModules
, self
, ...
}:
let
  reboudBud = bud self;
in
{
  _file = toString ./.;
  commands = [
    {
      category = "devos";
      package = reboudBud { inherit pkgs; };
    }
  ];
}
