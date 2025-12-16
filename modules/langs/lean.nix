{
  parts.lean = {
    enableIf.tags.personal = true;

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [lean4];
    };
  };
}
