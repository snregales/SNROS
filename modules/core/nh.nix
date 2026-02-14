{
  flake.modules.nixos.nh =
    { ... }:
    {
      programs.nh.enable = true;

      environment.shellAliases = {
        ns = "nh os switch";
        nb = "nh os boot";
        nt = "nh os test";
        nu = "nh os switch --update";
      };
    };
}
