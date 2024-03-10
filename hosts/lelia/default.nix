{ config, inputs, lib, modulesPath, pkgs, ... }: {
  imports = with inputs; [
    ../../global/hosts
    ../../optional/hosts/impermanence.nix
    ../../optional/users/joao
    ./disko-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen1
  ];

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    initrd = {
      availableKernelModules = [
        "ehci_pci"
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "thunderbolt"
        "usb_storage"
        "xhci_pci"
      ];
      postDeviceCommands =
        lib.mkAfter "zfs rollback -r zroot/ephemeral/root@blank";
    };

    kernelModules = [ "kvm-amd" ];
    kernelPackages =
      lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "boot.shell_on_fail" ];

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
      videoDrivers = [ "amdgpu" "modesetting" ];
    };

    openssh.enable = true;
    usbmuxd.enable = true;
    zfs.autoScrub.enable = true;
    zfs.trim.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [ tree xsel ];

    gnome.excludePackages = with (pkgs // pkgs.gnome); [
      gnome-photos
      gnome-tour
      atomix
      cheese
      epiphany
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

    sessionVariables = { NIXOS_OZONE_WL = "1"; };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    lxd.enable = true;
    lxd.recommendedSysctlSettings = true;
  };

  sops.defaultSopsFile = ./secrets.json;
  sops.secrets.luks_password.neededForUsers = true;

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  system.stateVersion = with lib; (versions.majorMinor version);
}
