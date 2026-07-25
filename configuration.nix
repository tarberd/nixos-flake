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

  boot.kernelParams = [
    "net.ifnames=0"
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  users.users.root = {
    hashedPassword = "$6$NvAm.r/Vdj43Y4gA$snMm90T2nBGPKRJjeCnAlHpcw/CtngbaIyE1Pc.NCd5JwhZbaudHGhtShPS4dI.ZRiWo30zKjR06rLQFdbhro.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6a46GEO27tNA42ehDQkZClA4oNWypBDiOyc86OkNWO bernardo.mferrari@gmail.com"
    ];
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  services.openssh.enable = true;

  networking.useDHCP = false;

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "206.83.40.77";
    prefixLength = 24;
  } ];

  networking.defaultGateway = {
    address = "206.83.40.1";
    interface = "ens18";
  };

  # Match your target release
  system.stateVersion = "26.05";
}
