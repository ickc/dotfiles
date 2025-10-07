{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          environment.systemPackages = import ./systemPackages.nix { inherit pkgs; };
          homebrew = {
            enable = true;
            onActivation.cleanup = "zap";
            masApps = import ./masApps.nix;
            brews = import ./brews.nix;
            casks = import ./casks.nix;
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
          # https://github.com/zhaofengli/nix-homebrew/issues/5#issuecomment-2412587886
          (
            { config, ... }:
            {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            }
          )
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
