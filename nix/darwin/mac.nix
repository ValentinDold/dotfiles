{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = "valdo";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git gh stow aerospace
    tmux neovim lazygit nodejs lima
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

  homebrew = {
    enable = true;
    casks = [ "firefox" "signal" "spotify"];
    onActivation.cleanup = "uninstall";
  };
}
