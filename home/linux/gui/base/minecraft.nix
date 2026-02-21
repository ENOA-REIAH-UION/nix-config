{
  pkgs,
  config,
  lib,
  xmcl,
  ...
}:
let
  cfg = config.modules.desktop.minecraft;
in
{
  options.modules.desktop = {
    minecraft = {
      enable = lib.mkEnableOption "Install Minecraft Launchers (Prism, XMCL)";
    };
  };

  imports = [
    xmcl.homeModules.xmcl
  ];

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [ prismlauncher ];

    programs.xmcl = {
      enable = true;
      commandLineArgs = [
        "--password-store=\"gnome-libsecret\""
      ];
      jres = [
        pkgs.jre8
        pkgs.temurin-jre-bin-17
      ];
    };
  };
}
