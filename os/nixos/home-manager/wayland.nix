{ config, pkgs, ... }:

{
  home.packages = [
		pkgs.kitty         # Terminal emulator
    pkgs.dunst         # Notification deamon
    pkgs.libnotify
    pkgs.swww          # Wallpaper deamon
    pkgs.rofi-wayland  # dmenu replacement for Wayland
  ];

#  xdg.portal = {
#    enable = true;
#    configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
#  };

  wayland.windowManager.hyprland = {
    enable = true;

    # The hyprland package to use
    #package = pkgs.hyprland;

    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;

		settings = {
			"$mod" = "SUPER";
			"exec-once" = [
        #"waybar"
        #"eww"
      ];
			bind = [
        "$mod, F, exec, firefox"
        ", Print, exec, grimblast copy area"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
            ws = let
            c = (x + 1) / 10;
            in
            builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
        )
        10)
      );
		};

	};
}
