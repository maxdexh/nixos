{
  parts.cpp = {
    enableIf.tags.personal = true;

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [gcc];
    };
  };
}
