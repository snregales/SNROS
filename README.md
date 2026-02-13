# SNROS

Declarative NixOS system configuration built with Nix Flakes. Manages machine configurations, development tooling, and a fully-configured Neovim IDE through a modular architecture.

## Project Structure

```
.
├── flake.nix                    # Flake entry point — inputs and outputs
├── flake.lock                   # Pinned dependency versions
├── justfile                     # Command runner recipes
├── .envrc                       # Direnv integration
├── .zellij/layouts/dev.kdl      # Development environment layout
└── modules/
    ├── flake-parts.nix          # Flake-parts module system
    ├── systems.nix              # Supported architectures (x86_64-linux)
    ├── nix-settings.nix         # Nix experimental features and nixpkgs config
    ├── devshell.nix             # Development shell packages
    ├── formatting.nix           # Code formatter (alejandra)
    ├── neovim.nix               # Neovim IDE configuration (nvf)
    ├── stylix.nix               # System-wide theming (Ayu Dark)
    └── configurations/
        └── nixos.nix            # NixOS configuration builder
```

## Prerequisites

- [Nix](https://nixos.org/download/) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic shell activation)

## Getting Started

Clone the repository and enter the development shell:

```sh
git clone <repo-url> && cd SNROS
direnv allow   # or: nix develop
```

Launch the full development environment:

```sh
just dev
```

This opens a [Zellij](https://zellij.dev/) session with three tabs:

| Tab | Contents |
|-----|----------|
| **editor** | Neovim with floating Claude CLI |
| **shell** | Nix shell + Lazygit side-by-side |
| **vm** | VM build runner + logs |

## Commands

All commands are run via [just](https://just.systems/):

```sh
just dev        # Launch Zellij development environment
just build-vm   # Build the NixOS VM
just run-vm     # Build and run the VM
just fmt        # Format all Nix files with alejandra
just check      # Run flake checks
just update     # Update flake inputs
```

## Flake Inputs

| Input | Purpose |
|-------|---------|
| [nixpkgs](https://github.com/NixOS/nixpkgs) (unstable) | Package repository |
| [flake-parts](https://github.com/hercules-ci/flake-parts) | Modular flake architecture |
| [import-tree](https://github.com/vic/import-tree) | Automatic module discovery |
| [home-manager](https://github.com/nix-community/home-manager) | User environment management |
| [niri](https://github.com/sodiboo/niri-flake) | Wayland scrollable-tiling window manager |
| [nvf](https://github.com/NotAShelf/nvf) | Neovim configuration framework |
| [stylix](https://github.com/nix-community/stylix) | System-wide theming |

## Modules

### `configurations/nixos.nix`

Defines a `configurations.nixos` option that maps attribute sets to `flake.nixosConfigurations`. Each entry takes a `module` (a deferred NixOS module) and produces a full `nixosSystem`.

### `devshell.nix`

Provides the default development shell with: alejandra, nil (Nix LSP), git, just, fzf, yazi, zellij, and a custom neovim build.

### `neovim.nix`

Full IDE configuration via nvf. Exported both as a NixOS module (`flake.modules.nixos.neovim`) and a standalone package (`packages.neovim`).

Key features:
- **Theme**: Base16 Ayu Dark
- **LSP**: lspconfig, lspsaga, lightbulb, trouble, format-on-save
- **Languages**: Nix, Lua, Rust, Python, C, Bash, HTML, YAML, Markdown
- **Treesitter**: 24 grammars with folding and context
- **Completion**: blink-cmp with signature help and LuaSnip snippets
- **Search**: FzfLua (files, grep, LSP symbols) and Snacks pickers
- **Git**: gitsigns, diffview, git pickers
- **Navigation**: flash.nvim, hop, leap
- **UI**: lualine, noice, which-key, colorizer, fidget, mini starter
- **Extras**: yazi file manager, project/session management, nvim-dap debugger, todo-comments

Leader key is `<Space>`. See `modules/neovim.nix` for the full keymap reference (80+ bindings).

### `stylix.nix`

Applies the Ayu Dark base16 color scheme system-wide via Stylix. Exposed as `flake.modules.nixos.stylix`.

### `formatting.nix`

Sets [alejandra](https://github.com/kamadorueda/alejandra) as the project-wide Nix formatter.

## Adding a NixOS Configuration

Define a new machine in any module under `modules/`:

```nix
{ ... }:
{
  configurations.nixos.my-machine = {
    module = { pkgs, ... }: {
      imports = [
        # hardware configuration, other modules...
      ];
      # NixOS options here
    };
  };
}
```

Then build it:

```sh
nix build .#nixosConfigurations.my-machine.config.system.build.toplevel
```

## License

TBD
