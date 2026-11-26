{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = "valdo";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git gh stow aerospace
    tmux neovim lazygit nodejs lima llama-cpp uv
    zoxide fzf fd tree
    zsh-autosuggestions zsh-syntax-highlighting
  ];

  # expose the zsh plugins under /run/current-system/sw/share
  environment.pathsToLink = [
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

  # your .zshrc runs compinit itself; avoid running it twice
  programs.zsh.enableCompletion = false;

  # sudo with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  # --- Dock -------------------------------------------------------------
  system.defaults.dock = {
    minimize-to-application = true;   # minimized windows go into the app icon
    persistent-others = [ ];          # no folders like Downloads
    show-recents = false;             # no recently used apps
    autohide = true;                  # hide the Dock until you move the mouse there
    autohide-delay = 0.0;             # ...without the delay
    launchanim = false;               # no bouncing icons when apps start
    mru-spaces = false;               # don't rearrange Spaces by recent use
    expose-group-apps = true;         # Mission Control groups windows by app
    wvous-br-corner = 1;              # disable the bottom-right hot corner
  };

  # --- Desktop ------------------------------------------------------------
  system.defaults.WindowManager = {
    EnableStandardClickToShowDesktop = false;
  };

  # --- Typing and general ---------------------------------------------------
  system.defaults.NSGlobalDomain = {
    NSAutomaticCapitalizationEnabled = false;      # no automatic capital letters
    NSAutomaticSpellingCorrectionEnabled = false;  # no autocorrect
    NSAutomaticPeriodSubstitutionEnabled = false;  # double space doesn't become ". "
    NSAutomaticQuoteSubstitutionEnabled = false;   # no curly quotes
    NSAutomaticDashSubstitutionEnabled = false;    # -- doesn't become a dash
    ApplePressAndHoldEnabled = false;              # holding a key repeats it
    KeyRepeat = 2;                                 # fast key repeat
    InitialKeyRepeat = 15;                         # short delay before repeating
    AppleShowAllExtensions = true;                 # always show file extensions
    NSDocumentSaveNewDocumentsToCloud = false;     # save to disk, not iCloud
    NSNavPanelExpandedStateForSaveMode = true;     # save dialog always expanded
  };

  # --- Finder ---------------------------------------------------------------
  system.defaults.finder = {
    ShowPathbar = true;                     # path bar at the bottom
    FXPreferredViewStyle = "Nlsv";          # list view by default
    FXEnableExtensionChangeWarning = false; # no warning when renaming extensions
    FXDefaultSearchScope = "SCcf";          # search the current folder
    _FXShowPosixPathInTitle = true;         # full path in the window title
  };

  # no .DS_Store files on network drives and USB sticks
  system.defaults.CustomUserPreferences."com.apple.desktopservices" = {
    DSDontWriteNetworkStores = true;
    DSDontWriteUSBStores = true;
  };

  # --- Screenshots ------------------------------------------------------------
  system.defaults.screencapture = {
    location = "~/Pictures/Screenshots";
    disable-shadow = true;
  };

  # --- Apps at login ------------------------------------------------------------
  launchd.user.agents.syncthing.serviceConfig = {
    ProgramArguments = [ "/usr/bin/open" "-g" "-j" "-a" "Syncthing" ];
    RunAtLoad = true;
  };

  # --- Homebrew apps --------------------------------------------------------------
  homebrew = {
    enable = true;
    casks = [ "firefox" "discord" "iina" "anki" "signal" "spotify" "syncthing-app" ];
    onActivation.cleanup = "uninstall";
  };
}
