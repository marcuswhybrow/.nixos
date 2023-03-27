{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in {
    nixosConfigurations.marcus-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./platform.nix
        ./hardware.nix
        ./kernel.nix
        ./filesystem.nix
        ./boot.nix
        ./networking.nix
        ./localisation.nix
        ./audio.nix
        ./bar
        ./configuration.nix
	home-manager.nixosModules.home-manager
	{
          custom = {
            platform = "x86_64-linux";
            hardware.cpu = "intel";
            kernel.modules.beforeMountingRoot = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
            kernel.virtualisation.enable = true;
            filesystem = {
              boot = { device = "/dev/sda1"; fsType = "vfat"; mountPoint = "/boot/efi"; };
              root = { device = "/dev/sda2"; fsType = "ext4"; isEncrypted = true; };
              swap = { device = "/dev/sda3"; isEncrypted = true; };
            };
            boot.mountPoint = "/boot/efi";
            networking.hostName = "marcus-laptop";
            localisation.timeZone = "Europe/London";
            localisation.locale = "en_GB.UTF-8";
            audio.enable = true;
          };
	  home-manager = {
	    useGlobalPkgs = true;
	    useUserPackages = true;
	    users.marcus = import ./home.nix;
	    extraSpecialArgs = { inherit pkgs; };
          };
	}
      ];
    };
  };
}
