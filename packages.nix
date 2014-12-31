{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aacolorize
    apg
    ascii
    aspellDicts.de
    aspellDicts.en
    axbo
    bc
    beets
    chromiumBeta
    dash
    dos2unix
    erlang
    fbida
    ffmpeg
    figlet
    firefox
    flac
    gajim
    gdb
    ghostscript
    gimp
    glxinfo
    gnumake
    gnupg1compat
    graphviz
    haskellPackages.cabal2nix
    haskellPackages.cabalInstall
    haskellPackages.hlint
    haskellPackages.yesodBin
    haxe
    hexedit
    i3
    i3lock
    imagemagick
    jwhois
    keychain
    lastwatch
    lftp
    ltrace
    manpages
    miro
    mmv
    mosh
    mp3info
    mpg321
    mpv
    mtr
    mutt
    ncdu
    neko
    netrw
    nix-prefetch-scripts
    nix-repl
    nixops
    nixpkgs-lint
    nmap
    openssh
    openssl
    p7zip
    pavucontrol
    picard
    posix_man_pages
    pulseaudio
    pvolctrl
    python
    python3
    pythonPackages.hetzner
    pythonPackages.pep8
    pythonPackages.polib
    rlwrap
    rtorrent
    samplicator
    screen
    scrot
    socat
    sox
    sqlite
    strace
    surfraw
    taskwarrior
    telnet
    tomahawk
    unzip
    uqm
    valgrind
    vbindiff
    vorbisTools
    w3m
    wireshark
    xpdf
    youtubeDL
  ];
}
