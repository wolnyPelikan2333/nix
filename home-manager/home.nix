{ pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.username = "michal";
  home.homeDirectory = "/home/michal";

  #########################################################
  # Pakiety użytkownika
  #########################################################
  home.packages = [
    pkgs.nodejs_22
    pkgs.zsh
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.vscode-langservers-extracted
    pkgs.nodePackages.bash-language-server
    pkgs.ripgrep
    pkgs.fzf
    pkgs.fd
    pkgs.git
    pkgs.nil
    pkgs.starship
    pkgs.direnv
    pkgs.zoxide
    pkgs.fastfetch
    pkgs.bat
    pkgs.eza
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
  ];

  #########################################################
  # Neovim
  #########################################################
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  home.file.".config/nvim/init.lua".text = ''
    -- NEOVIM – Lazy.nvim + Plugins
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function()
          vim.cmd.colorscheme("catppuccin")
        end
      },
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
      { "neovim/nvim-lspconfig" },
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "L3MON4D3/LuaSnip" }
    })

    -- Ustawienia podstawowe
    vim.g.mapleader = " "
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.expandtab = true
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    vim.opt.smartindent = true
    vim.opt.termguicolors = true

    -- LSP Setup
    local lsp = vim.lsp
    lsp.start({ name = "ts_ls", cmd = { "typescript-language-server", "--stdio" } })
    lsp.start({ name = "bashls", cmd = { "bash-language-server", "start" } })
    lsp.start({ name = "nil_ls", cmd = { "nil" } })
  '';

  #########################################################
  # Zsh + Starship
  #########################################################
  programs.zsh = {
    enable = true;

    initExtra = ''
      # STARSHIP
      eval "$(starship init zsh)"

      # VIM MOTION
      bindkey -v
      bindkey '^H' backward-char
      bindkey '^L' forward-char
      bindkey '^W' backward-kill-word
      bindkey '^U' kill-whole-line

      # Zsh plugins
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      # fzf, direnv, zoxide
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"

      # Editor & history
      export EDITOR=nvim
      export VISUAL=nvim
      HISTSIZE=50000
      SAVEHIST=50000
      HISTFILE=~/.zsh_history

      # FZF default command
      export FZF_DEFAULT_COMMAND="fd --type f"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # ---- automatyczny start Zsh w Bashu ----
      if [ -n "$BASH_VERSION" ]; then
        exec zsh
      fi
    '';
  };

  #########################################################
  # Starship config
  #########################################################
  home.file.".config/starship.toml".text = ''
add_newline = false
format = "$directory $git_branch ❯ "

[directory]
style = "cyan"
truncation_length = 3

[git_branch]
symbol = " "
style = "green"
format = "[$symbol$branch]($style)"
truncation_length = 5

[git_status]
style = "red"
disabled = false

[character]
success_symbol = "❯"
error_symbol = "❯"
vicmd_symbol = "❮"
style_success = "blue"
style_error = "red"
style_vicmd = "yellow"
'';
}

