{
  parts.lean = {
    tags = ["personal"];

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [lean4];
    };
  };
}
