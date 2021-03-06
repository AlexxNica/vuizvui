{ pkgs, lib, ... }:

let
  vaultPath = "/dev/mapper/${vaultDevice.name}";

  mkDevice = category: num: uuid: {
    name = "dnyarri-${category}-crypt-${toString num}";
    device = "/dev/disk/by-uuid/${uuid}";
    keyFile = vaultPath;
    keyFileSize = 1048576;
  };

  vaultDevice = {
    name = "dnyarri-crypt-vault";
    device = "/dev/disk/by-uuid/61e971d2-be93-4e60-8266-b2c6a71e2dc8";
  };

  cryptDevices = {
    root = lib.imap (mkDevice "root") [
      "b13d257e-b5fd-4f86-82b1-8bfe06335a75"
      "a607c827-2fd7-49d9-a7d8-05279c8653a4"
      "de32cb42-2e09-4e6a-84b4-244078d289c8"
      "12dac5b2-7647-45de-b752-5efee23855d0"
    ];
    swap = lib.imap (mkDevice "swap") [
      "e0a8281d-2c68-48ca-8e00-f0defaf51f38"
      "d26e61d6-c238-4c01-8c57-b1ba0bdb8c93"
    ];
  };

in {
  vuizvui.user.aszlig.profiles.workstation.enable = true;

  nix.maxJobs = 8;

  boot = {
    loader.systemd-boot.enable = true;
    loader.grub.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = true;

    initrd = {
      availableKernelModules = [
        "aes_x86_64" "af_alg" "algif_skcipher" "cbc" "cryptd" "crypto_simd"
        "dm_crypt" "ecb" "gf128mul" "glue_helper" "xts"
      ];

      luks.devices = lib.singleton vaultDevice
                  ++ lib.concatLists (lib.attrValues cryptDevices);
      postDeviceCommands = lib.mkAfter ''
        cryptsetup luksClose ${lib.escapeShellArg vaultPath}
      '';
    };
  };

  environment.systemPackages = [ pkgs.paperwork ];

  # This is very ugly and I really want to avoid non-free packages on all
  # of my workstations. But right now I need to get rid of useless paper.
  nixpkgs.config = {
    allowUnfreePredicate = pkg: let
      inherit (builtins.parseDrvName pkg.name) name;
    in name == "hplip";
    packageOverrides = super: {
      hplip = super.hplip.override { withPlugin = true; };
    };
  };

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplip ];

  vuizvui.user.aszlig.system.kernel.enable = true;
  hardware.enableAllFirmware = true;

  networking.hostName = "dnyarri";

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/9A75-9A6E";
      fsType = "vfat";
    };
    "/" = {
      label = "dnyarri-root";
      fsType = "btrfs";
      options = [ "autodefrag" "space_cache" "compress=lzo" "noatime" ];
    };
  };

  powerManagement.powerUpCommands = ''
    ${pkgs.hdparm}/sbin/hdparm -B 255 /dev/disk/by-id/ata-ST31500541AS_5XW0AMNH
    ${pkgs.hdparm}/sbin/hdparm -B 255 /dev/disk/by-id/ata-ST31500541AS_6XW0M217
  '';

  swapDevices = map ({ name, ... }: {
    device = "/dev/mapper/${name}";
  }) cryptDevices.swap;

  users.users.aszlig.extraGroups = [
    "scanner"
    # TODO: Try to avoid this, but as there is only a single user using audio
    # on this machine, it's okay for now. But remember that this will break
    # heavily, should there be another user accessing the audio devices.
    "audio"
  ];

  services.xserver.videoDrivers = [ "ati" ];
  services.xserver.xrandrHeads = [ "DVI-0" "HDMI-0" ];

  vuizvui.user.aszlig.services.i3.workspaces."1" = {
    label = "XMPP";
    assign = lib.singleton { class = "^(?:Tkabber|Gajim)\$"; };
  };

  vuizvui.user.aszlig.services.i3.workspaces."3" = {
    label = "Chromium";
    assign = lib.singleton { class = "^Chromium(?:-browser)?\$"; };
  };
}
