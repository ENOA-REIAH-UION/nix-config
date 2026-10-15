{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    # https://starship.rs/config/
    settings = {
      # Get editor completions based on the config schema
      "$schema" = "https://starship.rs/config-schema.json";

      # I never rely on the defaults, so this module is useless to me—disabled.
      # I prefer adding --project, --region to very gcloud/aws command.
      aws.disabled = true;
      gcloud.disabled = true;

      kubernetes = {
        symbol = "⛵";
        disabled = false;
      };

    };
  };
}
