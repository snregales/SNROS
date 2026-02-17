_: {
  flake.modules.homeManager.zellij = _: {
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        simplified_ui = true;
        default_layout = "compact";
        copy_command = "wl-copy";
        show_startup_tips = false;
        pane_frames = false;
      };
    };
  };
}
