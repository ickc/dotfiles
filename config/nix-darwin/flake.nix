{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [ 
          bat
          binutils
          bottom
          cmake
          coreutils
          darwin.iproute2mac
          difftastic
          diffutils
          dua
          duti
          entr
          epubcheck
          exiftool
          fastfetch
          ffmpeg_7
          findutils
          fzf
          gawk
          gh
          ghostscript
          git
          glances
          gnugrep
          gnumake
          gnupatch
          gnused
          gnutar
          go
          go-task
          graphviz
          gron
          gzip
          highlight
          html-tidy
          htop
          hyperfine
          imagemagick
          inetutils
          iperf3
          jq
          julia-bin
          less
          libimobiledevice
          lynx
          mediainfo
          mediainfo-gui
          mosh
          mpv
          nano
          neofetch
          nmap
          onefetch
          opencc
          pam-reattach
          parallel
          pdf2svg
          potrace
          ranger
          rsync
          shfmt
          smartmontools
          sshuttle
          time
          tmux
          tree
          units
          unzip
          w3m
          wakeonlan
          watch
          wdiff
          wget
          which
          wtf
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Kolens-MacBook-Pro
    darwinConfigurations."Kolens-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Kolens-MacBook-Pro".pkgs;
  };
}
