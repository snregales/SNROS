_: {
  flake.modules.homeManager.himalaya = {osConfig, ...}: {
    programs.himalaya.enable = true;

    accounts.email.accounts.gmail = {
      primary = true;
      address = osConfig.snros.user.email;
      realName = osConfig.snros.user.name;
      userName = osConfig.snros.user.email;
      passwordCommand = "op read op://snros/himalaya/password";

      imap = {
        host = "imap.gmail.com";
        port = 993;
        tls.enable = true;
      };

      smtp = {
        host = "smtp.gmail.com";
        port = 465;
        tls.enable = true;
      };

      folders = {
        inbox = "INBOX";
        sent = "[Gmail]/Sent Mail";
        drafts = "[Gmail]/Drafts";
        trash = "[Gmail]/Trash";
      };

      himalaya.enable = true;
    };
  };
}
