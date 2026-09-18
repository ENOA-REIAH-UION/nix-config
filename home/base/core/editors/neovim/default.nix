{ pkgs, ... }:
{
  programs = {
    neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;

      withRuby = false;
      withPython3 = false;
    };
  };
  home.file.".config/nvim".source = ./nvim;
  home.packages = with pkgs; [
    tree-sitter
  ];
}
