{
  parts.lean = {
    tags = ["default"];

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [lean4];
    };
  };
}
