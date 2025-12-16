{
  parts.tex = {
    enableIf.tags.personal = true;

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [
        texliveFull
      ];
    };
  };
}
