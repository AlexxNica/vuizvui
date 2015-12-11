system: path:

let
  nixpkgs = import ../nixpkgs-path.nix;

in rec {
  config = import path;
  build = import "${nixpkgs}/nixos/lib/eval-config.nix" {
    inherit system;
    modules = [ config ] ++ import ../modules/module-list.nix;
  };
  iso = let
    isoModule = "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix";
    patchedModule = (import nixpkgs {}).runCommand "iso-image.nix" {} ''
      sed -e 's|../../../lib/|${nixpkgs}/nixos/lib/|g' \
          -e 's/"nomodeset"//g' \
          "${isoModule}" > "$out"
    '';
    wrapIso = { config, pkgs, lib, ... }@attrs: let
      eval = (import patchedModule attrs);
      evalcfg = eval.config or {};
      bootcfg = evalcfg.boot or {};
      fscfg = evalcfg.fileSystems or {};
    in {
      options = eval.options or {};
      imports = eval.imports or [];
      config = evalcfg // {
        boot = bootcfg // lib.optionalAttrs (bootcfg ? loader) {
          loader = lib.mkForce bootcfg.loader;
        };
        fileSystems = lib.mapAttrs (lib.const lib.mkForce) fscfg // {
          "/boot" = lib.mkForce (fscfg."/boot" or {
            device = "none";
            fsType = "none";
            options = "noauto";
          });
        };
      };
    };
  in import "${nixpkgs}/nixos/lib/eval-config.nix" {
    inherit system;
    modules = [
      use wrapIso
      (
        { lib, ... }: let
          name = build.config.networking.hostName;
          upperName = lib.toUpper name;
        in rec {
          isoImage.isoName = "${name}.iso";
          isoImage.volumeID = builtins.substring 0 11 "${upperName}_LIVE";
          isoImage.makeEfiBootable = true;
          isoImage.makeUsbBootable = true;
          isoImage.appendToMenuLabel = " \"${name}\" Live System";
        }
      )
    ];
  };
  use = {
    imports = [ config ] ++ import ../modules/module-list.nix;
  };
  vm = (import "${nixpkgs}/nixos" {
    inherit system;
    configuration = use;
  }).vm;
}