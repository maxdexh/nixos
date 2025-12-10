{
  parts.tex = {
    tags = ["default"];

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [
        texliveFull
      ];
    };
  };
}
