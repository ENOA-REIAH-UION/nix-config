{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nixpaks.firefox
  ];

  # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
  programs.google-chrome = {
    enable = false;
    package = if pkgs.stdenv.isAarch64 then pkgs.chromium else pkgs.google-chrome;
  };
}
