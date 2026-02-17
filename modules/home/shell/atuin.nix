_: {
  flake.modules.homeManager.atuin = _:
    {
      programs.atuin = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          min_cmd_len = 3;
          history_filter = [
            "password"
            "passwd"
            "secret"
            "token"
            "api.key"
            "API_KEY"
            "SECRET"
            "TOKEN"
            "PASSWORD"
            "PASSWD"
          ];
        };
      };
    };
}
