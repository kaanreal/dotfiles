{ config, ... }:

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

  # Lock the graphics and memory clocks to avoid idle-state wake-up stutter
  # (NVIDIA on Wayland at 2560x1440@180). The RTX 3050 reports 1552 MHz as
  # the selected graphics step and 7001 MHz as its supported memory clock.
  # Reset anytime with `nvidia-smi -rgc` and `nvidia-smi -rmc`.
  systemd.services.nvidia-clocks = {
    description = "Lock NVIDIA graphics clock for stable frame pacing";
    after = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 2;
    };
    script = ''
      ${config.hardware.nvidia.package.bin}/bin/nvidia-modprobe
      ${config.hardware.nvidia.package.bin}/bin/nvidia-modprobe -c0 -u
      ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pm 1
      locked=0
      for i in 1 2 3 4 5; do
        ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -lgc 1552,1552 \
          && ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -lmc 7001,7001 \
          && locked=1 \
          && break
        sleep 2
      done
      test "$locked" -eq 1
      ${config.hardware.nvidia.package.bin}/bin/nvidia-smi \
        --query-gpu=clocks.gr,clocks.mem \
        --format=csv,noheader
    '';
  };
}
