{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # nixpkgs.config.allowUnfree = true;
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
            code2prompt
            coreutils-full
            delta
            devbox
            # diffoscope
            difftastic
            diffutils
            direnv
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
            gh
            ghostscript
            git
            gnugrep
            gnumake
            gnupatch
            gnused
            gnutar
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
            less
            libarchive
            libimobiledevice
            librsvg
            lsd
            lux
            mactop
            mediainfo
            mediainfo-gui
            minify
            mosh
            nano
            nixd
            nixfmt-rfc-style
            nmap
            onefetch
            openai-whisper
            openai-whisper-cpp
            opencc
            pam-reattach
            parallel
            pdf2svg
            poppler_utils
            potrace
            procps
            ripgrep
            rsync
            sd
            shellcheck
            shfmt
            smartmontools
            sshuttle
            starship
            streamlink
            time
            tmux
            tokei
            units
            w3m
            wakeonlan
            wdiff
            wget
            which
            yt-dlp
            zsh
          ];
          homebrew = {
            enable = true;
            onActivation.cleanup = "zap";
            masApps = {
              "1Blocker" = 1365531024;
              "Aiko" = 1672085276;
              "Amphetamine" = 937984704;
              "Blackmagic Disk Speed Test" = 425264550;
              "Compressor" = 424390742;
              "Copilot" = 6738511300;
              "Deliveries" = 290986013;
              "Drafts" = 1435957248;
              "EasyRes" = 688211836;
              "Final Cut Pro" = 424389933;
              "forScore" = 363738376;
              "FreeChat" = 6458534902;
              "GarageBand" = 682658836;
              "HACK" = 1464477788;
              "iThoughtsX" = 720669838;
              "JPEGmini Pro" = 887163276;
              "KeePassium" = 1435127111;
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
              "Perplexity" = 6714467650;
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
              "Tailscale" = 1475387142;
              "TaskPaper" = 1090940630;
              "The Camelizer" = 1532579087;
              "The Unarchiver" = 425424353;
              "Toggl Track" = 1291898086;
              "Trello" = 1278508951;
              "uBlacklist for Safari" = 1547912640;
              "URL Linker" = 1289119450;
              "Vinegar" = 1591303229;
              "WhatsApp" = 310633997;
              "Windows App" = 1295203466;
              "Xcode" = 497799835;
            };
            brews = [
              "ansible"
              "gemini-cli"
              "imageoptim-cli"
              "llama.cpp"
              "macmon"
              "mas"
              "mermaid-cli"
              "mpv"
              "pandoc"
              "verapdf"
            ];
            casks = [
              "accordance"
              "adobe-creative-cloud"
              "adobe-dng-converter"
              "alt-tab"
              "amethyst"
              "appcleaner"
              "astropad"
              "audacity"
              "background-music"
              "betterdisplay"
              "calibre"
              "chatgpt"
              "claude"
              "clockify"
              "dataspell"
              "detexify"
              "discord"
              "disk-inventory-x"
              "displaylink"
              "dropbox"
              "dupeguru"
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
              "font-jetbrains-mono-nerd-font"
              "font-latin-modern-math"
              "font-latin-modern"
              "font-noto-sans-cjk"
              "font-noto-serif-cjk"
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
              "ghostty"
              "gimp"
              "github"
              "google-chrome"
              "google-drive"
              "grandperspective"
              "handbrake"
              "heynote"
              "imagealpha"
              "imageoptim"
              "inkscape"
              "jan"
              "jetbrains-toolbox"
              "joplin"
              "jordanbaird-ice"
              "jupyterlab-app"
              "keepassxc"
              "keka"
              "keymapp"
              "kitty"
              "kiwix"
              "libreoffice"
              "lm-studio"
              "logos"
              "logseq"
              "mactex"
              "makemkv"
              "marked-app"
              "microsoft-auto-update"
              "microsoft-teams"
              "musescore"
              "namechanger"
              "netdownloadhelpercoapp"
              "notion-calendar"
              "notion"
              "obsidian"
              # "onedrive"
              "r-app"
              "raindropio"
              "rectangle"
              "rstudio"
              "scoot"
              "sdformatter"
              "shortcat"
              "signal"
              "spotify"
              "steam"
              "textmate"
              "utm"
              "visual-studio-code"
              "vlc"
              "wezterm"
              "whatsapp"
              "xquartz"
              "yattee"
              "zed"
              "zed@preview"
              "zerotier-one"
              "zettlr"
              "zoom"
              "zotero"
            ];
          };

          # Necessary for using flakes on this system.
          nix.settings = {
            download-buffer-size = 256 * 1024 * 1024;
            experimental-features = "nix-command flakes";
            trusted-users = [
              "root"
              "@admin"
            ];
          };

          programs.bash = {
            enable = true;
            completion.enable = true;
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

          security.pam.services.sudo_local.touchIdAuth = true;

          system.primaryUser = "kolen";
          # ids.gids.nixbld = 350;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 4;

          system.defaults = {
            LaunchServices.LSQuarantine = false;
            NSGlobalDomain = {
              AppleInterfaceStyle = "Dark";
              AppleInterfaceStyleSwitchesAutomatically = false;
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
          # https://gist.github.com/tkafka/e3eb63a5ec448e9be6701bfd1f1b1e58
          launchd.user.agents.environment-fix-electron-resource-hog-bug.serviceConfig = {
            Label = "environment.fix-electron-resource-hog-bug";
            ProgramArguments = [
              "/bin/launchctl"
              "setenv"
              "CHROME_HEADLESS"
              "1"
            ];
            RunAtLoad = true;
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;
              enableRosetta = false;
              user = "kolen";
              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
              };
              # Automatically migrate existing Homebrew installations
              autoMigrate = true;
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."simple".pkgs;
    };
}
