{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages.install = pkgs.writeShellApplication {
      name = "snros-install";
      runtimeInputs = with pkgs; [
        git
        openssh
        ssh-to-age
        sbctl
        inputs.disko.packages.${system}.disko
      ];
      text = builtins.readFile ../scripts/install.sh;
    };
  };
}
