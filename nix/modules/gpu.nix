{ config, pkgs, lib, ... }:

{
  hardware.graphics.enable = true;
  # 32-bit GL stack (mesa32 + nvidia lib32) at /run/opengl-driver-32/lib,
  # needed by 32-bit clients like the Steam/Wine UI.
  hardware.graphics.enable32Bit = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    branch = "latest";
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Lock the graphics clock to avoid clock-turbo stutter (NVIDIA on Wayland).
  # Runs as root at boot; reset anytime with `nvidia-smi -rgc`.
  systemd.services.nvidia-clocks = {
    description = "Lock NVIDIA graphics clock for stable frame pacing";
    after = [ "display-manager.service" ];
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pm 1
      for i in 1 2 3 4 5; do
        ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -lgc 1550,1550 && break
        sleep 2
      done
      ${config.hardware.nvidia.package.bin}/bin/nvidia-smi --query-gpu=clocks.gr --format=csv,noheader
    '';
  };
}
