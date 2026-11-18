{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = "valdo";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git gh stow aerospace
  ];

  homebrew = {
    enable = true;
    casks = [ "firefox" ];
    onActivation.cleanup = "uninstall";
  };
}
