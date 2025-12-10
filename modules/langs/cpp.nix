{
  parts.cpp = {
    tags = ["default"];

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [gcc];
    };
  };
}
