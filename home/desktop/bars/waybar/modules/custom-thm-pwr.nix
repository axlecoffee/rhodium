{
  waybarModules = {
    "custom/thm-pwr" = {
      exec = "$XDG_BIN_HOME/waybar/custom-thermals.sh gpupower";
      return-type = "json";
      format = "󱒀 G {text}";
      tooltip = true;
      tooltip-format = "GPU Wattage";
      interval = 1;
    };
  };
}
