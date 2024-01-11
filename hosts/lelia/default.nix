# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, inputs, lib, modulesPath, pkgs, ... }: {
  imports = with inputs; [
    ../../common/hosts
    ../../common/users/joao
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
      availableKernelModules = [
        "nvme"
        "ehci_pci"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      postDeviceCommands =
        lib.mkAfter "zfs rollback -r zroot/ephemeral/root@blank";
    };

    kernelModules = [ "kvm-amd" ];
    kernelPackages =
      lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
    zfs.forceImportRoot = false;
  };

  hardware.pulseaudio.enable = false;

  networking = {
    hostName = builtins.baseNameOf ./.;
    hostId = "8425e349";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };

  sound.enable = true;

  security = {
    rtkit.enable = true;
    sudo.extraConfig = "Defaults lecture = never";
    sudo.wheelNeedsPassword = false;
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
      videoDrivers = [ "amdgpu" ];
      xkbVariant = "";
    };

    openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/keep/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/keep/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
      ];
    };
  };

  fileSystems."/keep".neededForBoot = true;

  environment = {
    systemPackages = with pkgs; [ tree xsel ];

    gnome.excludePackages = with (pkgs // pkgs.gnome); [
      gnome-photos
      gnome-tour
      atomix
      cheese
      epiphany
      evince
      geary
      gedit
      gnome-characters
      gnome-music
      gnome-terminal
      hitori
      iagno
      tali
      totem
    ];

    persistence."/keep" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/log"
      ];
      files = [ "/etc/machine-id" ];
    };

    sessionVariables = { NIXOS_OZONE_WL = "1"; };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
  };

  sops.secrets = let
    fromJSON' = path: builtins.fromJSON (builtins.readFile path);
    removeSopsKey = set: lib.filterAttrs (key: _: key != "sops") set;

    format = "json";
    neededForUsers = true;
    sopsFile = ./secrets.json;
  in lib.mapAttrs' (key: _: {
    name = "${config.networking.hostName}/${key}";
    value = { inherit format key neededForUsers sopsFile; };
  }) (removeSopsKey (fromJSON' sopsFile));

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "x86_64-linux";
    overlays = [ inputs.wayland-pkgs.overlay ];
  };

  system.stateVersion = with lib; (versions.majorMinor version);
}
