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
    hardware.nixosModules.lenovo-legion-y530-15ich
    impermanence.nixosModules.impermanence
  ];

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    initrd = {
      availableKernelModules =
        [ "ahci" "nvme" "sd_mod" "usb_storage" "usbhid" "xhci_pci" ];
      postDeviceCommands =
        lib.mkAfter "zfs rollback -r zroot/ephemeral/root@blank";
    };

    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "intel_iommu=on" "iommu=pt" ];
    zfs.forceImportRoot = false;
  };

  hardware = {
    cpu.amd.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
    pulseaudio.enable = false;
  };

  networking = {
    hostName = builtins.baseNameOf ./.;
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

  time.timeZone = "Europe/Stockholm";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console.keyMap = "br-abnt2";

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

  environment = {
    systemPackages = with pkgs; [ tree xsel ];

    gnome.excludePackages = (with pkgs; [ gnome-photos gnome-tour ])
      ++ (with pkgs.gnome; [
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
      ]);

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
  };

  fileSystems."/keep".neededForBoot = true;

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
