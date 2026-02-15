# Algo's NixOS Config

{ config, lib, pkgs, ... }:

let

# reaper-wrapped script credit to Man2 of the NixOS Discord.
# Gets Reaper plugins like spectral-compressor working
reaper-wrapped = pkgs.symlinkJoin {
	name = "reaper-wrapped";
	paths = [ pkgs.reaper ];
	buildInputs = [ pkgs.makeWrapper ];
	postBuild = ''
		wrapProgram $out/bin/reaper \
		--prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
			pkgs.xorg.libxcb
			pkgs.xorg.xcbutilwm
			pkgs.xorg.libX11
			pkgs.xorg.libXcursor
			pkgs.xorg.libXrandr
			pkgs.libGL
		]}
	'';
};

in

{
imports = [
	./hardware-configuration.nix
	/home/algo/.musnix/musnix
];

# Use the systemd-boot EFI boot loader.
boot.loader = {
	systemd-boot.enable = true;
	systemd-boot.configurationLimit = 3;
	efi.canTouchEfiVariables = true;
	timeout = 10;
};

system.stateVersion = "25.11"; # Don't touch this. It won't update your system.

networking.hostName = "melis";
networking.networkmanager.enable = true;

# Locale
i18n.defaultLocale = "en_US.UTF-8";
i18n.extraLocaleSettings = {
	LC_ALL = "en_US.UTF-8";
};

time.timeZone = "America/Los_Angeles";

# Services
services = {
	desktopManager.plasma6.enable = true;
	displayManager.sddm.enable = true;
	displayManager.sddm.theme = "catppuccin-mocha-rosewater";
	displayManager.sddm.wayland.enable = true;
};

services.pipewire = {
	enable = true;
	pulse.enable = true;
	alsa.enable = true;
	jack.enable = true;
};

services.syncthing = {
	enable = true;
	openDefaultPorts = true;
    group = "users";
    user = "algo";
    dataDir = "/home/algo";
    configDir = "/home/algo/.config/syncthing";
};

services.journald.extraConfig = "SystemMaxUse=100M";

# User
users.users.algo = {
	isNormalUser = true;
	extraGroups = [ "wheel" "audio" "networkmanager" ];
	packages = with pkgs; [
		tree
	];
	shell = pkgs.fish;
	useDefaultShell = true;
};

programs.fish.enable = true;
programs.steam.enable = true;

musnix.enable = true;

nixpkgs.config.allowUnfree = true; # Allows proprietary packages.

environment.systemPackages = with pkgs; [
    # Basics
	nano
	neovim
	wget
	fastfetch
	gcc
	glibc
	cmake
	python3
	openssh
	git
	gh # git cli
	unzip
	libGL
	toybox # Unix Command Line Utils
	ffmpeg
	dbus
	gtk2
	xwayland
	wayland-utils
	xdg-desktop-portal
	electron
	wl-clipboard
	hardinfo2
	ffmpeg
	dxvk
	cargo
	rustc
	libva-utils
	vulkan-tools
	# KDE
	kdePackages.kcalc
	kdePackages.kclock
	kdePackages.sddm-kcm
	kdePackages.partitionmanager
	kdePackages.xdg-desktop-portal-kde
	kdePackages.plasma-pa
	kdePackages.ktorrent
	# Theming
	(pkgs.catppuccin-papirus-folders.override {
		flavor = "mocha";
		accent = "rosewater";
	})
	(pkgs.catppuccin-sddm.override {
		flavor = "mocha";
		accent = "rosewater";
		disableBackground = true;
	})
	# Applications
	vlc
	ghostty # Meta+T
	librewolf # Meta+E
	zoom-us
	obs-studio
	prismlauncher
	element-desktop
	fluffychat
	obsidian # Meta+R, open with command line arg --disable-gpu
	vesktop # Turn off hardware acceleration
	bitwarden-desktop
	libreoffice-qt
	# Musicking
	reaper-wrapped
	pwvucontrol
	wireplumber
	qpwgraph
	yabridge
	yabridgectl
	wineWowPackages.yabridge # wine-staging 9.21
	winetricks
	alsa-lib
	alsa-oss
	alsa-utils
	# Music Plugins
	decent-sampler
	surge-XT
	plugdata
	vital
	airwindows-lv2
	chow-tape-model
];

environment.plasma6.excludePackages = with pkgs; [
	kdePackages.kdepim-runtime
	kdePackages.kmahjongg
	kdePackages.kmines
	kdePackages.konversation
	kdePackages.kpat
	kdePackages.ksudoku
	kdePackages.konqueror
	kdePackages.discover
];

}

