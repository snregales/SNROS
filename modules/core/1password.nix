_: {
  flake.modules.nixos._1password = _: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["snregales"];
    };
  };
}
