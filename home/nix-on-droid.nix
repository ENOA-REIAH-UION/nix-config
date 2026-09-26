# Lightweight Android user environment.
#
# This intentionally reuses the same Home Manager modules as the NixOS hosts,
# rather than maintaining a second copy of git/shell/editor configuration.
{
  imports = [
    ./base/core/git.nix
    ./base/core/shells/default.nix
    ./base/core/starship.nix
    ./base/core/editors/default.nix
    ./base/tui/editors/default.nix
  ];

  home.stateVersion = "25.11";

  home.sessionVariables = {

  };
}
