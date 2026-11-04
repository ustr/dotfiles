final: prev:
let
  piSrc = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    tag = "v1.5.0";
    hash = "sha256-eH3RuypmXeayuZ9lEag6KW3m2LSM4bDc4ogyHxjZMNI=";
  };
  piNix = prev.runCommand "pi-nix-patched" { } ''
    cp -r ${piSrc}/nix $out
    chmod -R u+w $out
    sed -i \
      -e 's|      pack_package packages/mcp mcp|      pack_package packages/mcp mcp\n      pack_package packages/schema schema|' \
      -e 's|      "node_modules/@earendil-works/pi-mcp" = workspacePackages + "/mcp.tgz";|      "node_modules/@earendil-works/pi-mcp" = workspacePackages + "/mcp.tgz";\n      "node_modules/@earendil-works/pi-schema" = workspacePackages + "/schema.tgz";|' \
      $out/package.nix
    grep -q pi-schema $out/package.nix
  '';
in
{
  pi-coding-agent = prev.callPackage "${piNix}/package.nix" {
    source = piSrc;
  };
}
