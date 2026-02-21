_: {
  flake.modules.homeManager.brave = _: {
    programs.brave = {
      enable = true;
      extensions = [
        {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # sponsorblock
        {id = "aapbdbdomjkkjkaonfhkkikfgjllcleb";} # google translate
        {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1password
        {id = "hfjbmagddngcpeloejdejnfgbamkjaeg";} # vimium c
      ];
    };
  };
}
