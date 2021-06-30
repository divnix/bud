{ stdProfilePath, ... }:
{ flk.cmds = {

  # Onboarding
  up.script = ./onboarding/up.bash;
  get.script = ./onboarding/get.bash;
  
  # Utils
  update.script = ./utils/update.bash;
  repl.script = ./utils/repl.bash;
  ssh-show.script = ./utils/ssh-show.bash;

  # Home-Manager
  home.script = ./hm/home.bash;

  # Hosts
  build.script = ./hosts/build.bash;
  vm.script = ./hosts/vm.bash;
  vm-run.script = ./hosts/vm-run.bash;
  install.script = ./hosts/install.bash;
  rebuild.script = ./hosts/rebuild.bash;

}; }
