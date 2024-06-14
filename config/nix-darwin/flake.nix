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
          btop
          clang-tools
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
          f3
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
          gpsbabel
          graphviz
          gron
          gzip
          highlight
          html-tidy
          htop
          hyperfine
          imagemagick
          imagemagick
          inetutils
          iperf3
          joshuto
          jq
          julia-bin
          less
          libimobiledevice
          lsd
          lux
          lynx
          mactop
          mediainfo
          mediainfo-gui
          memtester
          minify
          mosh
          mpv
          nano
          neofetch
          nmap
          onefetch
          openai-whisper-cpp
          opencc
          pam-reattach
          pandoc
          parallel
          pdf2svg
          pixi
          potrace
          qmk
          ranger
          rsync
          shellcheck
          shfmt
          smartmontools
          sshuttle
          starship
          streamlink
          subversion
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
          youtube-dl
          yt-dlp
          zellij
        ];

      homebrew.masApps = {
        "1Blocker" = 1365531024;
        "Amphetamine" = 937984704;
        "Blackmagic Disk Speed Test" = 425264550;
        "Compressor" = 424390742;
        "Deliveries" = 290986013;
        "Drafts" = 1435957248;
        "EasyRes" = 688211836;
        "Excel" = 462058435;
        "Final Cut Pro" = 424389933;
        "forScore" = 363738376;
        "GarageBand" = 682658836;
        "HACK" = 1464477788;
        "iThoughtsX" = 720669838;
        "JPEGmini Pro" = 887163276;
        "Keynote" = 409183694;
        "Logic Pro X" = 634148309;
        "MainStage 3" = 634159523;
        "Microsoft OneNote" = 784801555;
        "Microsoft Outlook" = 985367838;
        "Motion" = 434290957;
        "MultiMarkdown Composer v4" = 1275176220;
        "Numbers" = 409203825;
        "OneDrive" = 823766827;
        "Pages" = 409201541;
        "PowerPoint" = 462062816;
        "Prime Video" = 545519333;
        "Rakuten Cash Back" = 1451893560;
        "SafariMarkdownLinker" = 1289119450;
        "Save to Raindrop.io" = 1549370672;
        "Slack" = 803453959;
        "SMARTReporter" = 509148961;
        "Spark" = 1176895641;
        "Speedtest" = 1153157709;
        "Strongbox" = 897283731;
        "Tab Switcher" = 1406718335;
        "Tabs to Links" = 1451408472;
        "TaskPaper" = 1090940630;
        "The Camelizer" = 1532579087;
        "The Unarchiver" = 425424353;
        "Trello" = 1278508951;
        "uBlacklist for Safari" = 1547912640;
        "Vinegar" = 1591303229;
        "Word" = 462054704;
        "Xcode" = 497799835;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      security.pam.enableSudoTouchIdAuth = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      system.defaults = {
        LaunchServices.LSQuarantine = false;
        NSGlobalDomain = {
          AppleInterfaceStyleSwitchesAutomatically = true;
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = 1;
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          AppleTemperatureUnit = "Celsius";
          AppleWindowTabbingMode = "always";
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = true;
          NSAutomaticSpellingCorrectionEnabled = false;
          "com.apple.mouse.tapBehavior" = 1;
          "com.apple.sound.beep.feedback" = 0;
          "com.apple.trackpad.enableSecondaryClick" = true;
          "com.apple.trackpad.forceClick" = true;
        };
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
        dock = {
          autohide = true;
          minimize-to-application = true;
          mru-spaces = false;
          show-recents = false;
          wvous-bl-corner = 5;
          wvous-tl-corner = 10;
        };
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "clmv";
          QuitMenuItem = true;
          ShowPathbar = true;
          _FXShowPosixPathInTitle = false;
        };
        loginwindow = {
          DisableConsoleAccess = false;
          GuestEnabled = false;
          PowerOffDisabledWhileLoggedIn = true;
          RestartDisabledWhileLoggedIn = true;
          ShutDownDisabledWhileLoggedIn = true;
        };
        magicmouse.MouseButtonMode = "TwoButton";
        menuExtraClock = {
          ShowAMPM = true;
          ShowDate = 1;
          ShowDayOfWeek = true;
        };
        screensaver = {
          askForPassword = true;
          askForPasswordDelay = 5;
        };
        spaces.spans-displays = false;
        trackpad = {
          ActuationStrength = 0;
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = true;
          TrackpadThreeFingerTapGesture = 0;
        };
      };

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
