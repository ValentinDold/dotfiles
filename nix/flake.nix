{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nix-darwin, ... }: {
    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/mac.nix ];
    };
  };
}
