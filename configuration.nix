{ config, pkgs, ... }:

{
  #########################################################
  # IMPORTS
  #########################################################
  imports = [
    ./hardware-configuration.nix
    # Home Manager moduł dla NixOS 25.05
    (import (builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz") {}).nixos
  ];

  programs.zsh.enable = true;

  #########################################################
  # SYSTEM & LOCALE
  #########################################################
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "pl_PL.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  #########################################################
  # DISPLAY & DESKTOP
  #########################################################
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb.layout = "pl";
  console.keyMap = "pl2";

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "michal";

  #########################################################
  # BLUETOOTH + AUDIO
  #########################################################
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
    bluez_monitor.properties = {
      ["bluez5.enable-sbc-xq"] = true;
      ["bluez5.enable-msbc"] = true;
      ["bluez5.enable-hw-volume"] = true;
      ["bluez5.enable-aac"] = true;
      ["bluez5.enable-ldac"] = true;
    }
  '';

  #########################################################
  # NVIDIA
  #########################################################
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  #########################################################
  # UNFREE
  #########################################################
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  #########################################################
  # BOOTLOADER
  #########################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #########################################################
  # SYSTEM PACKAGES
  #########################################################
  environment.systemPackages = with pkgs; [
    wget
    google-chrome
    lutris
    vscode
    steam
    kdePackages.okular
    softmaker-office
    btop
    neofetch
    thunderbird
  ];

  # ZSH JAKO POWŁOKA SYSTEMOWA
  environment.shells = [
    pkgs.zsh
  ];

  users.defaultUserShell = pkgs.zsh;

  #########################################################
  # UŻYTKOWNIK SYSTEMOWY
  #########################################################
  users.users.michal = {
    isNormalUser = true;
    description = "michal";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  #########################################################
  # HOME MANAGER – NEOVIM + JS/TS/NIX
  #########################################################
  home-manager.users.michal = {
    home.stateVersion = "25.05";

    programs.home-manager.enable = true;

    home.packages = [
      pkgs.nodejs_22
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.pyright
      pkgs.ripgrep
      pkgs.fzf
      pkgs.fd
    ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };

    # KONFIGURACJA NEOVIM
    home.file.".config/nvim/init.lua".text = ''
      -- =========================
      -- NEOVIM – PLUGIN MANAGER
      -- =========================
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
        -- MIEJSCE NA TWOJE WTYCZKI
        -- Dodawaj tu kolejne wtyczki w formacie:
        -- { "autor/nazwa-wtyczki" }

        { "ellisonleao/gruvbox.nvim", priority = 1000, config = function()
            vim.cmd.colorscheme("gruvbox")
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

      -- AUTOMATYCZNE INSTALOWANIE WSZYSTKICH WTYCZEK
      vim.cmd([[autocmd User LazyVimStarted ++once Lazy sync]])

      -- BASIC SETTINGS
      vim.g.mapleader = " "
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.termguicolors = true

      -- LSP SETUP
      local lspconfig = require("lspconfig")
      lspconfig.tsserver.setup{}
      lspconfig.pyright.setup{}
      lspconfig.nil_ls.setup{}
    '';
  };

  #########################################################
  # SYSTEM VERSION
  #########################################################
  system.stateVersion = "25.05";
}

