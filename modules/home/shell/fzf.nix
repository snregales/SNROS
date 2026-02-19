_: {
  flake.modules.homeManager.fzf = _: {
    programs = {
      fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultOptions = [
          "--margin=1"
          "--layout=reverse"
          "--border=none"
          "--info=hidden"
          "--prompt='/ '"
          "--no-bold"
          "--preview='bat --style=numbers --color=always --line-range :500 {}'"
          "--preview-window=right:60%:wrap"
        ];
      };

      zsh.shellAliases = {
        fvim = "fzf --bind='enter:become(nvim {})'";
      };

      zsh.initContent = ''
        function _fzf_edit() {
          local file
          file="$(fzf --walker-root="''${1:-.}" --bind='enter:become(echo {})')"
          if [ -n "$file" ]; then
            ''${EDITOR:-nvim} "$file"
          fi
          zle reset-prompt
        }

        function _fzf_cwd_widget() { _fzf_edit; }
        function _fzf_home_widget() { _fzf_edit ~; }

        function _fzf_zvm_keybindings() {
          zvm_define_widget _fzf_cwd_widget
          zvm_define_widget _fzf_home_widget
          # <leader>f: fzf -> $EDITOR in cwd (normal mode)
          zvm_bindkey vicmd ' f' _fzf_cwd_widget
          # <leader>F: fzf -> $EDITOR in home (normal mode)
          zvm_bindkey vicmd ' F' _fzf_home_widget
        }
        zvm_after_lazy_keybindings_commands+=(_fzf_zvm_keybindings)
      '';
    };
  };
}
