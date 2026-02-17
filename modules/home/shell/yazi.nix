_: {
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      plugins = with pkgs.yaziPlugins; {
        inherit
          chmod
          git
          glow
          mount
          ouch
          relative-motions
          smart-enter
          smart-filter
          starship
          ;
      };
    };

    programs.zsh.initContent = ''
      # yazi file picker: open selected file in $EDITOR
      function _yazi_edit() {
        local tmp="$(mktemp -t "yazi-chooser.XXXXXX")"
        yazi "$@" --chooser-file="$tmp"
        if [ -s "$tmp" ]; then
          ''${EDITOR:-nvim} "$(<"$tmp")"
        fi
        rm -f -- "$tmp"
        zle reset-prompt
      }

      function _yazi_cwd_widget() { _yazi_edit; }
      function _yazi_home_widget() { _yazi_edit ~; }

      function _yazi_zvm_keybindings() {
        zvm_define_widget _yazi_cwd_widget
        zvm_define_widget _yazi_home_widget
        # <leader>.: yazi in cwd (normal mode)
        zvm_bindkey vicmd ' .' _yazi_cwd_widget
        # <leader>,: yazi in home (normal mode)
        zvm_bindkey vicmd ' ,' _yazi_home_widget
      }
      zvm_after_lazy_keybindings_commands+=(_yazi_zvm_keybindings)
    '';
  };
}
