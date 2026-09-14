{ lib, pkgs, nu_scripts, ... }:

{
  user.shell = "${pkgs.nushell}/bin/nu";

  environment.sessionVariables.SHELL = "${pkgs.nushell}/bin/nu";
}
