{
  parts.tex = {
    tags = ["personal"];

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [
        texliveFull
      ];
    };
  };
}
