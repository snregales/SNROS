{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
in {
  config.vim = {
    # General
    vimAlias = true;
    viAlias = true;
    withNodeJs = true;
    spellcheck.enable = true;

    clipboard = {
      enable = true;
      providers.wl-copy.enable = true;
      registers = "unnamedplus";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    options = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;
      smartindent = true;
      list = true;
      listchars = "tab:» ,trail:·,nbsp:␣";
      wrap = true;
      breakindent = true;
      colorcolumn = "100";
      swapfile = false;
      backup = false;
      undofile = true;
      inccommand = "split";
      incsearch = true;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      background = "dark";
      scrolloff = 10;
      signcolumn = "yes";
      backspace = "indent,eol,start";
      splitright = true;
      splitbelow = true;
      updatetime = 250;
      timeoutlen = 300;
      hlsearch = true;
      cursorline = true;
      guicursor = "c:block-blinkon1,i:ver20-blinkon1,v:hor20";
      mouse = "a";
      showmode = false;
      confirm = true;
    };

    # LSP
    lsp = {
      enable = true;
      formatOnSave = true;
      lspkind.enable = true;
      lightbulb.enable = true;
      lspsaga.enable = true;
      lspconfig.enable = true;
      trouble.enable = true;
      otter-nvim.enable = true;
    };

    # Languages
    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;
      lua = {
        enable = true;
        lsp.lazydev.enable = true;
      };
      nix = {
        enable = true;
        format.type = ["alejandra"];
      };
      bash.enable = true;
      rust.enable = true;
      clang.enable = true;
      python = {
        enable = true;
        format.type = ["ruff"];
      };
      markdown = {
        enable = true;
        extensions.render-markdown-nvim = {
          enable = true;
          setupOpts.render-modes = ["n" "c" "t"];
        };
      };
      html.enable = true;
      yaml.enable = true;
    };

    # Treesitter
    treesitter = {
      enable = true;
      fold = true;
      context.enable = true;
      grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        c
        diff
        html
        javascript
        jsdoc
        json
        json5
        lua
        luadoc
        luap
        markdown
        markdown_inline
        nix
        printf
        python
        query
        regex
        rust
        toml
        tsx
        typescript
        vim
        vimdoc
        xml
        yaml
      ];
    };

    # Fuzzy finder
    fzf-lua = {
      enable = true;
      profile = "fzf-native";
    };

    # Autocomplete
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts.signature.enabled = true;
    };

    snippets.luasnip.enable = true;

    # Statusline
    statusline.lualine.enable = true;

    # Git
    git = {
      enable = true;
      gitsigns.enable = true;
    };

    # Autopairs
    autopairs.nvim-autopairs.enable = true;

    # File manager
    utility.yazi-nvim = {
      enable = true;
      mappings = {
        yaziToggle = "<leader>fE";
        openYaziDir = "<leader>fe";
      };
      setupOpts = {
        open_for_directories = true;
        floating_window_scaling_factor = 0.7;
        yazi_floating_window_winblend = 30;
        yazi_floating_window_border = "none";
        integration = {
          resolve_relative_path_application = "realpath";
          grep_in_directory = mkLuaInline ''
            function(directory)
              require("fzf-lua").grep({ cwd = directory })
            end
          '';
          grep_in_selected_files = mkLuaInline ''
            function(selected_files)
              require("fzf-lua").grep({ files = selected_files })
            end
          '';
        };
        keymaps = {
          grep_in_directory = "<c-f>";
          replace_in_directory = "<c-r>";
          send_to_quickfix_list = "Q";
          open_and_pick_window = "W";
          open_file_in_tab = false;
        };
      };
    };

    # Snacks
    utility.snacks-nvim.enable = true;
    utility.surround.enable = true;
    utility.diffview-nvim.enable = true;
    utility.motion = {
      flash-nvim.enable = true;
      hop.enable = true;
      leap.enable = true;
    };
    utility.images.image-nvim = {
      enable = true;
      setupOpts.backend = "kitty";
    };

    # Projects & sessions
    projects.project-nvim.enable = true;
    session.nvim-session-manager.enable = true;

    # Visuals
    visuals = {
      nvim-web-devicons.enable = true;
      fidget-nvim.enable = true;
      highlight-undo.enable = true;
    };

    # Binds
    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    comments.comment-nvim.enable = true;

    # UI
    ui = {
      noice.enable = true;
      colorizer.enable = true;
      smartcolumn = {
        enable = true;
        setupOpts.colorcolumn = "100";
      };
      fastaction.enable = true;
    };

    # Mini
    mini = {
      icons.enable = true;
      starter.enable = true;
    };

    # Debugger
    debugger.nvim-dap.enable = true;

    notes.todo-comments.enable = true;

    # Autocmds
    augroups = [
      {
        name = "highlight-yank";
        clear = true;
      }
      {
        name = "close-with-q";
        clear = true;
      }
      {
        name = "man-unlisted";
        clear = true;
      }
      {
        name = "wrap-spell";
        clear = true;
      }
      {
        name = "auto-create-dir";
        clear = true;
      }
      {
        name = "resize-splits";
        clear = true;
      }
      {
        name = "last-loc";
        clear = true;
      }
    ];

    autocmds = [
      {
        desc = "Highlight on yank";
        event = ["TextYankPost"];
        group = "highlight-yank";
        callback = mkLuaInline ''
          function()
            (vim.hl or vim.highlight).on_yank()
          end
        '';
      }
      {
        desc = "Close some filetypes with <q>";
        event = ["FileType"];
        group = "close-with-q";
        pattern = [
          "PlenaryTestPopup"
          "checkhealth"
          "dbout"
          "gitsigns-blame"
          "grug-far"
          "help"
          "lspinfo"
          "neotest-output"
          "neotest-output-panel"
          "neotest-summary"
          "notify"
          "qf"
          "spectre_panel"
          "startuptime"
          "tsplayground"
        ];
        callback = mkLuaInline ''
          function(event)
            vim.bo[event.buf].buflisted = false
            vim.schedule(function()
              vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
              end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
              })
            end)
          end
        '';
      }
      {
        desc = "Make it easier to close man-files when opened inline";
        event = ["FileType"];
        group = "man-unlisted";
        pattern = ["man"];
        callback = mkLuaInline ''
          function(event)
            vim.bo[event.buf].buflisted = false
          end
        '';
      }
      {
        desc = "Wrap and check for spell in text filetypes";
        event = ["FileType"];
        group = "wrap-spell";
        pattern = ["text" "plaintex" "typst" "gitcommit" "markdown"];
        callback = mkLuaInline ''
          function(event)
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
          end
        '';
      }
      {
        desc = "Auto create dir when saving a file";
        event = ["BufWritePre"];
        group = "auto-create-dir";
        callback = mkLuaInline ''
          function(event)
            if event.match:match("^%w%w+:[\\/][\\/]") then
              return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
      }
      {
        desc = "Resize splits if window got resized";
        event = ["VimResized"];
        group = "resize-splits";
        callback = mkLuaInline ''
          function(event)
            local current_tab = vim.fn.tabpagenr()
            vim.cmd("tabdo wincmd =")
            vim.cmd("tabnext " .. current_tab)
          end
        '';
      }
      {
        desc = "Go to last loc when opening a buffer";
        event = ["BufReadPost"];
        group = "last-loc";
        callback = mkLuaInline ''
          function(event)
            local exclude = { "gitcommit" }
            local buf = event.buf
            if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
              return
            end
            vim.b[buf].lazyvim_last_loc = true
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            local lcount = vim.api.nvim_buf_line_count(buf)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
      }
    ];

    # Keymaps
    keymaps = [
      # Visual line movement
      {
        key = "<s-down>";
        mode = ["v"];
        action = ":m '>+1<CR>gv=gv";
        desc = "Move lines down in visual selection";
      }
      {
        key = "<s-up>";
        mode = ["v"];
        action = ":m '<-2<CR>gv=gv";
        desc = "Move lines up in visual selection";
      }
      {
        key = "<";
        mode = ["v"];
        action = "<gv";
      }
      {
        key = ">";
        mode = ["v"];
        action = ">gv";
      }
      # Centered scrolling
      {
        key = "<c-d>";
        mode = ["n"];
        action = "<c-d>zz";
      }
      {
        key = "<c-u>";
        mode = ["n"];
        action = "<c-u>zz";
      }
      {
        key = "n";
        mode = ["n"];
        action = "nzzzv";
      }
      {
        key = "N";
        mode = ["n"];
        action = "Nzzzv";
      }
      # Clear highlights
      {
        key = "<esc>";
        mode = ["n"];
        action = ":nohl<cr>";
      }
      {
        key = "<leader>nh";
        mode = ["n"];
        action = ":nohl<CR>";
        desc = "Clear search highlights";
      }
      # Clipboard / register helpers
      {
        key = "<leader>fP";
        mode = ["n"];
        action = ''
          function()
            local filePath = vim.fn.expand("%:~")
            vim.fn.setreg("+", filePath)
            print("File path copied to clipboard: " .. filePath)
          end
        '';
        lua = true;
        desc = "Copy filepath to clipboard";
      }
      {
        key = "x";
        mode = ["n"];
        action = ''[["_x]]'';
        lua = true;
      }
      {
        key = "p";
        mode = ["v"];
        action = ''[["_dp]]'';
        lua = true;
      }
      {
        key = "<leader>p";
        mode = ["x"];
        action = ''[["_dP]]'';
        desc = "Paste without replacing register";
        lua = true;
      }
      {
        key = "<leader>d";
        mode = ["n" "v"];
        action = ''[["_d]]'';
        desc = "Delete without setting register";
        lua = true;
      }
      # General
      {
        key = "<leader>qq";
        mode = ["n"];
        action = "<cmd>qa<cr>";
        desc = "Quit All";
      }
      {
        key = "<leader>fn";
        mode = ["n"];
        action = "<cmd>enew<cr>";
        desc = "New File";
      }
      # Comments
      {
        key = "gco";
        mode = ["n"];
        action = "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
        desc = "Add Comment Below";
      }
      {
        key = "gcO";
        mode = ["n"];
        action = "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>";
        desc = "Add Comment Above";
      }
      # Buffers
      {
        key = "<leader>bb";
        mode = ["n"];
        action = "<cmd>bnext<cr>";
        desc = "Next Buffer";
      }
      {
        key = "<leader>bB";
        mode = ["n"];
        action = "<cmd>bprevious<cr>";
        desc = "Previous Buffer";
      }
      # Tabs
      {
        key = "<leader><tab>l";
        mode = ["n"];
        action = "<cmd>tablast<cr>";
        desc = "Last Tab";
      }
      {
        key = "<leader><tab>o";
        mode = ["n"];
        action = "<cmd>tabonly<cr>";
        desc = "Close Other Tabs";
      }
      {
        key = "<leader><tab>f";
        mode = ["n"];
        action = "<cmd>tabfirst<cr>";
        desc = "First Tab";
      }
      {
        key = "<leader><tab><tab>";
        mode = ["n"];
        action = "<cmd>tabnew<cr>";
        desc = "New Tab";
      }
      {
        key = "<leader><tab>>";
        mode = ["n"];
        action = "<cmd>tabnext<cr>";
        desc = "Next Tab";
      }
      {
        key = "<leader><tab>d";
        mode = ["n"];
        action = "<cmd>tabclose<cr>";
        desc = "Close Tab";
      }
      {
        key = "<leader><tab><";
        mode = ["n"];
        action = "<cmd>tabprevious<cr>";
        desc = "Previous Tab";
      }
      # fzf-lua
      {
        key = "<leader><leader>";
        mode = ["n"];
        action = "<cmd>FzfLua files<cr>";
        desc = "Search files by name";
      }
      {
        key = "<leader>/";
        mode = ["n"];
        action = "<cmd>FzfLua live_grep<cr>";
        desc = "Search files by contents";
      }
      {
        key = "<leader>ff";
        mode = ["n"];
        action = "<cmd>FzfLua files<cr>";
        desc = "Find files";
      }
      {
        key = "<leader>fr";
        mode = ["n"];
        action = "<cmd>FzfLua oldfiles<cr>";
        desc = "Recent";
      }
      {
        key = "<leader>gc";
        mode = ["n"];
        action = "<cmd>FzfLua git_commits<CR>";
        desc = "Commits";
      }
      {
        key = "<leader>sg";
        mode = ["n"];
        action = "<cmd>FzfLua live_grep<cr>";
        desc = "Search files by contents";
      }
      {
        key = "<leader>sw";
        mode = ["n"];
        action = "<cmd>FzfLua grep_cword<cr>";
        desc = "Search for WORD under cursor";
      }
      {
        key = "<leader>sw";
        mode = ["v"];
        action = "<cmd>FzfLua grep_visual<cr>";
        desc = "Search selection";
      }
      # fzf-lua LSP
      {
        key = "gd";
        mode = ["n"];
        action = "<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>";
        desc = "Goto Definition";
      }
      {
        key = "gr";
        mode = ["n"];
        action = "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>";
        desc = "References";
        nowait = true;
      }
      {
        key = "gI";
        mode = ["n"];
        action = "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>";
        desc = "Goto Implementation";
      }
      {
        key = "gy";
        mode = ["n"];
        action = "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>";
        desc = "Goto T[y]pe Definition";
      }
      # Snacks pickers
      {
        key = "<leader>;";
        mode = ["n"];
        action = "function() Snacks.picker.buffers() end";
        lua = true;
        desc = "Buffers";
      }
      {
        key = "<leader>:";
        mode = ["n"];
        action = "function() Snacks.picker.command_history() end";
        lua = true;
        desc = "Command history";
      }
      {
        key = "<leader>n";
        mode = ["n"];
        action = "function() Snacks.picker.notifications() end";
        lua = true;
        desc = "Notification History";
      }
      {
        key = "<leader>fb";
        mode = ["n"];
        action = "function() Snacks.picker.buffers() end";
        lua = true;
        desc = "Buffers";
      }
      {
        key = "<leader>fB";
        mode = ["n"];
        action = "function() Snacks.picker.buffers({ hidden = true, nofile = true }) end";
        lua = true;
        desc = "Buffers (all)";
      }
      {
        key = "<leader>fg";
        mode = ["n"];
        action = "function() Snacks.picker.git_files() end";
        lua = true;
        desc = "Find Files (git-files)";
      }
      {
        key = "<leader>fR";
        mode = ["n"];
        action = "function() Snacks.picker.recent({ filter = { cwd = true }}) end";
        lua = true;
        desc = "Recent (cwd)";
      }
      {
        key = "<leader>fp";
        mode = ["n"];
        action = "function() Snacks.picker.projects() end";
        lua = true;
        desc = "Projects";
      }
      {
        key = "<leader>gd";
        mode = ["n"];
        action = "function() Snacks.picker.git_diff() end";
        lua = true;
        desc = "Git Diff (hunks)";
      }
      {
        key = "<leader>gs";
        mode = ["n"];
        action = "function() Snacks.picker.git_status() end";
        lua = true;
        desc = "Git Status";
      }
      {
        key = "<leader>gS";
        mode = ["n"];
        action = "function() Snacks.picker.git_stash() end";
        lua = true;
        desc = "Git Stash";
      }
      {
        key = "<leader>sb";
        mode = ["n"];
        action = "function() Snacks.picker.lines() end";
        lua = true;
        desc = "Buffer Lines";
      }
      {
        key = "<leader>sB";
        mode = ["n"];
        action = "function() Snacks.picker.grep_buffers() end";
        lua = true;
        desc = "Grep Open Buffers";
      }
      {
        key = "<leader>sR";
        mode = ["n"];
        action = "function() Snacks.picker.registers() end";
        lua = true;
        desc = "Registers";
      }
      {
        key = "<leader>s/";
        mode = ["n"];
        action = "function() Snacks.picker.search_history() end";
        lua = true;
        desc = "Search History";
      }
      {
        key = "<leader>sa";
        mode = ["n"];
        action = "function() Snacks.picker.autocmds() end";
        lua = true;
        desc = "Autocmds";
      }
      {
        key = "<leader>sc";
        mode = ["n"];
        action = "function() Snacks.picker.command_history() end";
        lua = true;
        desc = "Command History";
      }
      {
        key = "<leader>sC";
        mode = ["n"];
        action = "function() Snacks.picker.commands() end";
        lua = true;
        desc = "Commands";
      }
      {
        key = "<leader>sd";
        mode = ["n"];
        action = "function() Snacks.picker.diagnostics() end";
        lua = true;
        desc = "Diagnostics";
      }
      {
        key = "<leader>sD";
        mode = ["n"];
        action = "function() Snacks.picker.diagnostics_buffer() end";
        lua = true;
        desc = "Buffer Diagnostics";
      }
      {
        key = "<leader>sh";
        mode = ["n"];
        action = "function() Snacks.picker.help() end";
        lua = true;
        desc = "Help Pages";
      }
      {
        key = "<leader>sH";
        mode = ["n"];
        action = "function() Snacks.picker.highlights() end";
        lua = true;
        desc = "Highlights";
      }
      {
        key = "<leader>si";
        mode = ["n"];
        action = "function() Snacks.picker.icons() end";
        lua = true;
        desc = "Icons";
      }
      {
        key = "<leader>sj";
        mode = ["n"];
        action = "function() Snacks.picker.jumps() end";
        lua = true;
        desc = "Jumps";
      }
      {
        key = "<leader>sk";
        mode = ["n"];
        action = "function() Snacks.picker.keymaps() end";
        lua = true;
        desc = "Keymaps";
      }
      {
        key = "<leader>sl";
        mode = ["n"];
        action = "function() Snacks.picker.loclist() end";
        lua = true;
        desc = "Location List";
      }
      {
        key = "<leader>sM";
        mode = ["n"];
        action = "function() Snacks.picker.man() end";
        lua = true;
        desc = "Man Pages";
      }
      {
        key = "<leader>sm";
        mode = ["n"];
        action = "function() Snacks.picker.marks() end";
        lua = true;
        desc = "Marks";
      }
      {
        key = "<leader>sr";
        mode = ["n"];
        action = "function() Snacks.picker.resume() end";
        lua = true;
        desc = "Resume";
      }
      {
        key = "<leader>sq";
        mode = ["n"];
        action = "function() Snacks.picker.qflist() end";
        lua = true;
        desc = "Quickfix List";
      }
      {
        key = "<leader>su";
        mode = ["n"];
        action = "function() Snacks.picker.undo() end";
        lua = true;
        desc = "Undotree";
      }
      {
        key = "<leader>uC";
        mode = ["n"];
        action = "function() Snacks.picker.colorschemes() end";
        lua = true;
        desc = "Colorschemes";
      }
    ];
  };
}
