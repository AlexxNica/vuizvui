{ config, pkgs, lib, ... }:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci" "usbhid" "sdhci_acpi" "mmc_block"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "fbcon=rotate:3" ];

  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    cdparanoia chromium figlet gajim gimp htop inkscape libreoffice mosh mpv
    pciutils skype vlc vuizvui.tomahawk wget youtubeDL
  ];

  fileSystems."/boot".device = "/dev/disk/by-uuid/A0D5-269D";
  fileSystems."/boot".fsType = "vfat";

  fileSystems."/".label = "tyree-root";
  fileSystems."/".fsType = "btrfs";

  swapDevices = lib.singleton {
    label = "tyree-swap";
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.pulseaudio.enable = true;

  i18n.consoleKeyMap = "de";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "tyree";
  networking.firewall.enable = false;
  networking.wireless.enable = true;
  networking.useNetworkd = true;

  nix.maxJobs = 1;
  nix.useChroot = true;
  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
    chromium.enablePepperFlash = true;
  };

  services.openssh.enable = true;
  services.tlp.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "bla";
  services.xserver.desktopManager.kde5.enable = true;
  services.xserver.synaptics.enable = true;
  services.xserver.wacom.enable = true;

  time.timeZone = "Europe/Berlin";

  users.extraUsers.bla = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "video" "wheel" ];
  };

  vuizvui.user.aszlig.programs.vim.enable = true;
}
