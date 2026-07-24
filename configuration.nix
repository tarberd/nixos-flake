{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6a46GEO27tNA42ehDQkZClA4oNWypBDiOyc86OkNWO bernardo.mferrari@gmail.com"
  ];

  # Match your target release
  system.stateVersion = "26.05";

  # Enable and configure btrbk for automated Btrfs snapshots
  services.btrbk.instances."vps-backup" = {
    onCalendar = "weekly"; # Systemd timer: runs automatically once a day at midnight
    settings = {
      # Keep all snapshots for at least 2 days regardless of retention schedule
      snapshot_preserve_min = "2d";

      # Retention policy: keep 7 daily, 4 weekly, and 6 monthly snapshots locally
      snapshot_preserve = "7d 4w 6m";

      volume = {
        "/partition-root" = {
          # Saves snapshots into our dedicated /.snapshots subvolume
          snapshot_dir = "@snapshots";

          subvolume = {
            "@root" = {};     # Snapshot the root filesystem (@root)
            "@home" = {};  # Snapshot user home directories (@home)
          };
        };
      };
    };
  };
}
