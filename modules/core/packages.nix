_: {
  flake.modules.nixos.packages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      nwg-displays # configure monitor configs via GUI
      onefetch # provides SNROS build info on current system
      wget # Tool For Fetching Files With Links

      # disk and storage
      duf # Utility For Viewing Disk Free (df) In Terminal
      dust # Utility For Viewing Disk Usage In Terminal
      dua # Interactive TUI Disk Utility
      file-roller # Archive Manager
      ripgrep # Improved Grep
      unrar # Tool For Handling .rar Files
      unzip # Tool For Handling .zip Files

      # media
      ffmpeg # Terminal Video / Audio Editing
      imv # GUI Image Viewing
      mpv # Incredible Video Player
      pavucontrol # For Editing Audio Levels & Devices
      playerctl # Allows Changing Media Volume Through Scripts
      socat # Needed For Screenshots

      # system monitoring and management
      bottom # Simple Terminal Based System Monitor
      inxi # CLI System Information Tool
      killall # For Killing All Instances Of Programs
      lm_sensors # Used For Getting Hardware Temps
      lshw # Detailed Hardware Information
      pciutils # Collection Of Tools For Inspecting PCI Devices
      systemd-manager-tui # Interactive systemd managemnet TUI
      usbutils # Good Tools For USB Devices
    ];
  };
}
