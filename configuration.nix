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

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
  };

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
    pkgs.neovim
    pkgs.curl
    pkgs.gitMinimal
    pkgs.wireguard-tools
  ];

  services.openssh.enable = true;

  networking = {
    useDHCP = false;
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
    };
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address = "206.83.40.77"; prefixLength = 24; }
        ];
        ipv6.addresses = [
          { address = "2a0f:9400:fa0:44::1"; prefixLength = 44; }
        ];
      };
    };
    wireguard.interfaces = {
      wg0 = {
        ips = [
	  "10.100.0.1/24"
	  "2a0f:9400:738f:1::1/64"
	];
	listenPort = 51820;
	postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
	'';
	postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';
	privateKeyFile = "/root/wireguard-keys/private";
	peers = [
	  {
	    # stanley
	    publicKey = "VNpR6K59HlEE9CRAiDxTkbFyZ0e5HCG8a+x7uyAdTmg=";
	    allowedIPs = [
	      "10.100.0.2/32"
	      "2a0f:9400:738f:1::2/128"
	    ];
	  }
	];
      };
    };
    defaultGateway = {
      address = "206.83.40.1";
      interface = "eth0";
    };
    defaultGateway6 = {
      address = "2a0f:9400:fa0::1";
      interface = "eth0";
    };
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
    ];
  };

  # Match your target release
  system.stateVersion = "26.05";
  # Enable Flakes and the modern Nix CLI globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
