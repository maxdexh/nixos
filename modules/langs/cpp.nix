{
  parts.cpp = {
    tags = ["personal"];

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [gcc];
    };
  };
}
