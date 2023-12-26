# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = with inputs; [
    # Include the results of the hardware scan.
    ./disko-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    disko.nixosModules.disko
    hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen1
    impermanence.nixosModules.impermanence
  ];

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    initrd = {
      availableKernelModules = ["nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      kernelModules = [];
      postDeviceCommands = lib.mkAfter "zfs rollback -r zroot/ephemeral/root@blank";
    };

    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
  };

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    pulseaudio.enable = false;
  };

  networking = {
    hostName = lib.mkDefault (builtins.baseNameOf ./.);
    hostId = "8425e349";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  sound.enable = true;

  security = {
    rtkit.enable = true;
    sudo.extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';
  };

  time.timeZone = "Europe/Copenhagen";

  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "da_DK.UTF-8";
      LC_IDENTIFICATION = "da_DK.UTF-8";
      LC_MEASUREMENT = "da_DK.UTF-8";
      LC_MONETARY = "da_DK.UTF-8";
      LC_NAME = "da_DK.UTF-8";
      LC_NUMERIC = "da_DK.UTF-8";
      LC_PAPER = "da_DK.UTF-8";
      LC_TELEPHONE = "da_DK.UTF-8";
      LC_TIME = "da_DK.UTF-8";
    };
  };

  console.keyMap = "dk-latin1";

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      layout = "dk";
      xkbVariant = "";
    };

    openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/keep/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
    ];

    persistence."/keep" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/log"
        {
          directory = "/home/joao";
          user = "joao";
          group = "users";
          mode = "0700";
        }
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  fileSystems."/keep".neededForBoot = true;

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  users.users.joao = {
    isNormalUser = true;
    description = "João";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      firefox
      tree
    ];
    hashedPassword = "$y$j9T$Oh.cj23V4oPosds0kR12p/$Dq18ZR07MmeAHvw1UxMjmd1wWnIbpwyYAaIX.nZ8h69";
  };

  system.stateVersion = "23.11";
}
