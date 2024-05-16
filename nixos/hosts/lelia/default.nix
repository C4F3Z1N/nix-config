{ config, inputs, lib, modulesPath, pkgs, ... }: {
  imports = with inputs; [
    ../../modules # == "default.nix";
    ../../modules/impermanence.nix
    ../../users/joao
    ./disko-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.lenovo-thinkpad-t14s-amd-gen1
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
    supportedLocales = [
      "en_DK.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
      "sv_SE.UTF-8/UTF-8"
    ];
  };

  console.keyMap = "dk-latin1";

  location.provider = "geoclue2";

  services = {
    host-gpg-agent.enable = true;
    openssh.enable = true;
    usbmuxd.enable = true;
    zfs.autoScrub.enable = true;
    zfs.trim.enable = true;

    gnome.gnome-keyring.enable = lib.mkForce false;

    geoclue2.enableWifi = false;

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
  };

  environment = {
    systemPackages = with pkgs; [ tree xsel ];

    gnome.excludePackages = with (pkgs // pkgs.gnome); [
      atomix
      cheese
      epiphany
      geary
      gedit
      gnome-clocks
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      gnome-weather
      hitori
      iagno
      seahorse
      tali
      totem
      yelp
    ];

    sessionVariables = { NIXOS_OZONE_WL = "1"; };
  };

  virtualisation = {
    incus.enable = true;
    libvirtd.enable = true;
    podman.enable = true;
  };

  sops.secrets.luks_password.neededForUsers = true;

  # TODO: modularize this setting;
  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "8G";
    MemoryMax = "10G";
  };

  nix.sshServe.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.autoUpgrade.enable = true;
  system.stateVersion = "23.11";
}
