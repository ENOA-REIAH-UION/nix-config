{ pkgs, config, ... }:
{
  programs = {
    neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;

      withRuby = false;
      withPython3 = false;

      sideloadInitLua = true;
    };
  };
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/base/core/editors/neovim/nvim";
  home.packages = with pkgs; [
    tree-sitter
  ];
}
