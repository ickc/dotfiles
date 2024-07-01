{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          nixpkgs.config.allowUnfree = true;
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            bashInteractive
            bat
            bat-extras.batdiff
            bat-extras.batgrep
            bat-extras.batman
            bat-extras.batpipe
            bat-extras.batwatch
            bat-extras.prettybat
            bottom
            btop
            clang-tools_18
            cmake
            coreutils
            delta
            difftastic
            diffutils
            dua
            duti
            entr
            epubcheck
            exiftool
            f3
            fastfetch
            fastgron
            fd
            ffmpeg_7
            file
            findutils
            fzf
            gawk
            gcc14
            gh
            ghc
            ghostscript
            git
            gnugrep
            gnumake
            gnupatch
            gnused
            gnutar
            go
            go-task
            gpsbabel
            graphviz
            gzip
            html-tidy
            htop
            hyperfine
            imagemagick
            inetutils
            iperf
            joshuto
            jq
            julia-bin
            less
            libarchive
            libimobiledevice
            lmstudio
            lsd
            lua54Packages.lua
            lua54Packages.luarocks
            lux
            mactop
            mediainfo
            mediainfo-gui
            minify
            mosh
            mpv
            nano
            nixfmt-rfc-style
            nmap
            nodejs_22
            nodePackages_latest.prettier
            onefetch
            openai-whisper-cpp
            opencc
            pam-reattach
            pandoc
            parallel
            pdf2svg
            pixi
            potrace
            procps
            ripgrep
            rsync
            rustup
            sd
            shellcheck
            shfmt
            smartmontools
            sshuttle
            starship
            streamlink
            stylish-haskell
            stylua
            time
            tmux
            tokei
            typescript
            units
            w3m
            wakeonlan
            wdiff
            wget
            which
            wtf
            youtube-dl
            yt-dlp
            zellij
            zsh
          ];
          homebrew = {
            enable = true;
            onActivation.cleanup = "zap";
            masApps = {
              "1Blocker" = 1365531024;
              "Amphetamine" = 937984704;
              "Compressor" = 424390742;
              "Deliveries" = 290986013;
              "Disk Speed Test" = 425264550;
              "Drafts" = 1435957248;
              "EasyRes" = 688211836;
              "Final Cut Pro" = 424389933;
              "forScore" = 363738376;
              "GarageBand" = 682658836;
              "HACK" = 1464477788;
              "iThoughtsX" = 720669838;
              "JPEGmini Pro" = 887163276;
              "Keynote" = 409183694;
              "Logic Pro" = 634148309;
              "MainStage" = 634159523;
              "Microsoft Excel" = 462058435;
              "Microsoft OneNote" = 784801555;
              "Microsoft Outlook" = 985367838;
              "Microsoft PowerPoint" = 462062816;
              "Microsoft Word" = 462054704;
              "Motion" = 434290957;
              "MultiMarkdown Composer" = 1275176220;
              "Notability" = 360593530;
              "Numbers" = 409203825;
              "OneDrive" = 823766827;
              "Pages" = 409201541;
              "Prime Video" = 545519333;
              "Rakuten Cash Back" = 1451893560;
              "Save to Raindrop.io" = 1549370672;
              "Slack" = 803453959;
              "SMARTReporter" = 509148961;
              "Spark Desktop" = 6445813049;
              "Spark" = 1176895641;
              "Speedtest" = 1153157709;
              "Strongbox" = 897283731;
              "Tabs Switcher" = 1406718335;
              "Tabs to Links" = 1451408472;
              "TaskPaper" = 1090940630;
              "The Camelizer" = 1532579087;
              "The Unarchiver" = 425424353;
              "Trello" = 1278508951;
              "uBlacklist for Safari" = 1547912640;
              "URL Linker" = 1289119450;
              "Vinegar" = 1591303229;
              "Xcode" = 497799835;
            };
            brews = [ "llama.cpp" ];
            casks = [
              "accordance"
              "adobe-creative-cloud"
              "adobe-dng-converter"
              "alacritty"
              "alt-tab"
              "amethyst"
              "appcleaner"
              "astropad"
              "background-music"
              "betterdisplay"
              "calibre"
              "chatgpt"
              "cheatsheet"
              "dataspell"
              "detexify"
              "discord"
              "disk-inventory-x"
              "dropbox"
              "dupeguru"
              "eloston-chromium"
              "firefox"
              "font-andika"
              "font-cardo"
              "font-charis-sil"
              "font-computer-modern"
              "font-doulos-sil"
              "font-et-book"
              "font-ezra-sil"
              "font-fira-code-nerd-font"
              "font-fira-code"
              "font-fira-mono"
              "font-fira-sans"
              "font-fontawesome"
              "font-gentium-plus"
              "font-han-nom-a"
              "font-hanamin"
              "font-hasklug-nerd-font"
              "font-input"
              "font-jetbrains-mono-nerd-font"
              "font-latin-modern-math"
              "font-latin-modern"
              "font-noto-sans-cjk-sc"
              "font-noto-sans-cjk-tc"
              "font-scheherazade"
              "font-source-code-pro"
              "font-source-sans-3"
              "font-source-serif-4"
              "font-tex-gyre-adventor"
              "font-tex-gyre-bonum-math"
              "font-tex-gyre-bonum"
              "font-tex-gyre-chorus"
              "font-tex-gyre-cursor"
              "font-tex-gyre-heros"
              "font-tex-gyre-pagella-math"
              "font-tex-gyre-pagella"
              "font-tex-gyre-schola-math"
              "font-tex-gyre-schola"
              "font-tex-gyre-termes-math"
              "font-tex-gyre-termes"
              "gimp"
              "github"
              "google-chrome"
              "google-drive"
              "handbrake"
              "inkscape"
              "jetbrains-toolbox"
              "jordanbaird-ice"
              "keepassxc"
              "keka"
              "keymapp"
              "kitty"
              "kiwix"
              "libreoffice"
              "logos"
              "logseq"
              "mactex"
              "makemkv"
              "marked"
              "microsoft-auto-update"
              "microsoft-edge"
              "musescore"
              "namechanger"
              "netdownloadhelpercoapp"
              "notion-calendar"
              "notion"
              "obsidian"
              "r"
              "raindropio"
              "rectangle"
              "rstudio"
              "sdformatter"
              "signal"
              "spotify"
              "steam"
              "textmate"
              "utm"
              "visual-studio-code"
              "vlc"
              "wezterm"
              "whatsapp"
              "windscribe"
              "xquartz"
              "yattee"
              "zed"
              "zerotier-one"
              "zotero"
            ];
          };

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          programs.bash = {
            enable = true;
            enableCompletion = true;
          };
          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh = {
            enable = true; # default shell on catalina
            enableBashCompletion = false;
            enableCompletion = false;
            enableFzfCompletion = true;
            enableFzfHistory = true;
            promptInit = "";
          };

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
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem { modules = [ configuration ]; };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."simple".pkgs;
    };
}
