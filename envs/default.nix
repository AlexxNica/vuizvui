pkgs:

with pkgs;

{
  aszligEnv = buildEnv {
    name = "aszlig-env";
    paths = let
      genAszligEnv = name: paths: buildEnv {
        name = "aszlig-${name}-packages";
        inherit paths;
        ignoreCollisions = true;
      };
      collection = import ../collections/aszlig.nix pkgs;
    in lib.mapAttrsToList genAszligEnv collection;
  };

  catapultEnv = myEnvFun {
    name = "catapult";
    buildInputs = [
      stdenv python pil
      pythonPackages.matplotlib
      pythonPackages.django
      pythonPackages.sqlite3
      pythonPackages.markdown
      pythonPackages.MySQL_python
      pythonPackages.setuptools
    ];
  };

  kernelEnv = myEnvFun {
    name = "kernel";
    extraCmds = ''
      export NIX_LDFLAGS="$NIX_LDFLAGS -lncurses"
    '';
    buildInputs = [
      stdenv ncurses
    ];
  };

  hetznerEnv = myEnvFun {
    name = "hetzner";
    buildInputs = [
      stdenv python
      pythonPackages.pexpect
    ];
  };

  rdwarfEnv = myEnvFun {
    name = "rdwarf";
    buildInputs = [
      stdenv python
      pythonPackages.numpy
      pythonPackages.pyaudio
      pythonPackages.curses
    ];
  };
}