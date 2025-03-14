# generated by zon2nix (https://github.com/Cloudef/zig2nix)
{
  lib,
  linkFarm,
  fetchurl,
  fetchgit,
  runCommandLocal,
  zig_0_14,
  name ? "zig-packages",
}:
with builtins;
with lib; let
  unpackZigArtifact = {
    name,
    artifact,
  }:
    runCommandLocal name
    {
      nativeBuildInputs = [zig_0_14];
    }
    ''
      hash="$(zig fetch --global-cache-dir "$TMPDIR" ${artifact})"
      mv "$TMPDIR/p/$hash" "$out"
      chmod 755 "$out"
    '';

  fetchZig = {
    name,
    url,
    hash,
  }: let
    artifact = fetchurl {inherit url hash;};
  in
    unpackZigArtifact {inherit name artifact;};

  fetchGitZig = {
    name,
    url,
    hash,
  }: let
    parts = splitString "#" url;
    url_base = elemAt parts 0;
    url_without_query = elemAt (splitString "?" url_base) 0;
    rev_base = elemAt parts 1;
    rev =
      if match "^[a-fA-F0-9]{40}$" rev_base != null
      then rev_base
      else "refs/heads/${rev_base}";
  in
    fetchgit {
      inherit name rev hash;
      url = url_without_query;
      deepClone = false;
    };

  fetchZigArtifact = {
    name,
    url,
    hash,
  }: let
    parts = splitString "://" url;
    proto = elemAt parts 0;
    path = elemAt parts 1;
    fetcher = {
      "git+http" = fetchGitZig {
        inherit name hash;
        url = "http://${path}";
      };
      "git+https" = fetchGitZig {
        inherit name hash;
        url = "https://${path}";
      };
      http = fetchZig {
        inherit name hash;
        url = "http://${path}";
      };
      https = fetchZig {
        inherit name hash;
        url = "https://${path}";
      };
    };
  in
    fetcher.${proto};
in
  linkFarm name [
    {
      name = "libxev-0.0.0-86vtc-ziEgDbLP0vihUn1MhsxNKY4GJEga6BEr7oyHpz";
      path = fetchZigArtifact {
        name = "libxev";
        url = "https://github.com/mitchellh/libxev/archive/3df9337a9e84450a58a2c4af434ec1a036f7b494.tar.gz";
        hash = "sha256-oKZqA9d79jHnp/HsqJWQE33Ffn5Ee5G4VnlQepQuY4o=";
      };
    }
    {
      name = "vaxis-0.1.0-BWNV_MHyCAARemSCSwwc3sA1etNgv7ge0BCIXspX6CZv";
      path = fetchZigArtifact {
        name = "vaxis";
        url = "git+https://github.com/rockorager/libvaxis#1e24e0dfb509e974e1c8713bcd119d0ae032a8c7";
        hash = "sha256-6p9aSklLTPV9epzGkXBg5SQfjxfTT+/SYLFPiM04VF0=";
      };
    }
    {
      name = "zigimg-0.1.0-lly-O-NTEABwkjg9_WM4uLQr_TtL-7jp375PsZJyugGN";
      path = fetchZigArtifact {
        name = "zigimg";
        url = "git+https://github.com/TUSF/zigimg#5102e09be233d372e9e05f4cb2ffbefba30bc1c0";
        hash = "sha256-0HYK5A8Jlx1WD1hdU07r+m2AXl6UuazFiZd7P3uh/wY=";
      };
    }
    {
      name = "zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM";
      path = fetchZigArtifact {
        name = "zg";
        url = "git+https://codeberg.org/atman/zg#4a002763419a34d61dcbb1f415821b83b9bf8ddc";
        hash = "sha256-fo3l6cjkrr/godElTGnQzalBsasN7J73IDIRmw7v1gA=";
      };
    }
    {
      name = "z2d-0.6.0-j5P_HvLdCABu-dXpCeRM7Uk4m16vULg1980lMNCQj4_C";
      path = fetchZigArtifact {
        name = "z2d";
        url = "https://github.com/vancluever/z2d/archive/1e89605a624940c310c7a1d81b46a7c5c05919e3.tar.gz";
        hash = "sha256-PEKVSUZ6teRbDyhFPWSiuBSe40pgr0kVRivIY8Cn8HQ=";
      };
    }
    {
      name = "zig_objc-0.0.0-Ir_Sp3TyAADEVRTxXlScq3t_uKAM91MYNerZkHfbD0yt";
      path = fetchZigArtifact {
        name = "zig_objc";
        url = "https://github.com/mitchellh/zig-objc/archive/3ab0d37c7d6b933d6ded1b3a35b6b60f05590a98.tar.gz";
        hash = "sha256-zn1tR6xhSmDla4UJ3t+Gni4Ni3R8deSK3tEe7DGzNXw=";
      };
    }
    {
      name = "N-V-__8AAB9YCQBaZtQjJZVndk-g_GDIK-NTZcIa63bFp9yZ";
      path = fetchZigArtifact {
        name = "zig_js";
        url = "https://deps.files.ghostty.org/zig_js-12205a66d423259567764fa0fc60c82be35365c21aeb76c5a7dc99698401f4f6fefc.tar.gz";
        hash = "sha256-fyNeCVbC9UAaKJY6JhAZlT0A479M/AKYMPIWEZbDWD0=";
      };
    }
    {
      name = "ziglyph-0.11.2-AAAAAHPtHwB4Mbzn1KvOV7Wpjo82NYEc_v0WC8oCLrkf";
      path = fetchZigArtifact {
        name = "ziglyph";
        url = "https://deps.files.ghostty.org/ziglyph-b89d43d1e3fb01b6074bc1f7fc980324b04d26a5.tar.gz";
        hash = "sha256-cse98+Ft8QUjX+P88yyYfaxJOJGQ9M7Ymw7jFxDz89k=";
      };
    }
    {
      name = "wayland-0.4.0-dev-lQa1kjfIAQCmhhQu3xF0KH-94-TzeMXOqfnP0-Dg6Wyy";
      path = fetchZigArtifact {
        name = "zig_wayland";
        url = "https://codeberg.org/ifreund/zig-wayland/archive/f3c5d503e540ada8cbcb056420de240af0c094f7.tar.gz";
        hash = "sha256-E77GZ15APYbbO1WzmuJi8eG9/iQFbc2CgkNBxjCLUhk=";
      };
    }
    {
      name = "zf-0.10.3-OIRy8bKIAACV6JaNNncXA68Nw2BUAD9JVfQdzjyoZQ-J";
      path = fetchZigArtifact {
        name = "zf";
        url = "https://github.com/natecraddock/zf/archive/03176fcf23fda543cc02a8675e92c1fe3b1ee2eb.tar.gz";
        hash = "sha256-HqS2NFUuTQkltFsQlZz4HYHgfhEUEkZY83NnCW2x5Sg=";
      };
    }
    {
      name = "vaxis-0.1.0-BWNV_K3yCACrTy3A5cbZElLyICx5a2O2EzPxmgVRcbKJ";
      path = fetchZigArtifact {
        name = "vaxis";
        url = "git+https://github.com/rockorager/libvaxis/?ref=main#6a37605dde55898dcca4769dd3eb1e333959c209";
        hash = "sha256-5DW2V2bVsHtSw7UMGvJ+P0FpXIf5kTNjrq2SMqU6FIk=";
      };
    }
    {
      name = "gobject-0.2.0-Skun7H6DlQDWCiNQtdE5TXYcCvx7MyjW01OQe5M_n_jV";
      path = fetchZigArtifact {
        name = "gobject";
        url = "https://github.com/jcollie/ghostty-gobject/releases/download/0.14.0-2025-03-11-16-1/ghostty-gobject-0.14.0-2025-03-11-16-1.tar.gz";
        hash = "sha256-eMmS9oysZheHwSCCvmOUSDJmP9zN7cAr6qqDIbz6EmY=";
      };
    }
    {
      name = "N-V-__8AAKrHGAAs2shYq8UkE6bGcR1QJtLTyOE_lcosMn6t";
      path = fetchZigArtifact {
        name = "wayland";
        url = "https://deps.files.ghostty.org/wayland-9cb3d7aa9dc995ffafdbdef7ab86a949d0fb0e7d.tar.gz";
        hash = "sha256-6kGR1o5DdnflHzqs3ieCmBAUTpMdOXoyfcYDXiw5xQ0=";
      };
    }
    {
      name = "N-V-__8AAKw-DAAaV8bOAAGqA0-oD7o-HNIlPFYKRXSPT03S";
      path = fetchZigArtifact {
        name = "wayland_protocols";
        url = "https://deps.files.ghostty.org/wayland-protocols-258d8f88f2c8c25a830c6316f87d23ce1a0f12d9.tar.gz";
        hash = "sha256-XO3K3egbdeYPI+XoO13SuOtO+5+Peb16NH0UiusFMPg=";
      };
    }
    {
      name = "N-V-__8AAKYZBAB-CFHBKs3u4JkeiT4BMvyHu3Y5aaWF3Bbs";
      path = fetchZigArtifact {
        name = "plasma_wayland_protocols";
        url = "https://deps.files.ghostty.org/plasma_wayland_protocols-12207e0851c12acdeee0991e893e0132fc87bb763969a585dc16ecca33e88334c566.tar.gz";
        hash = "sha256-XFi6IUrNjmvKNCbcCLAixGqN2Zeymhs+KLrfccIN9EE=";
      };
    }
    {
      name = "N-V-__8AAABBKARxrVb9mEr7T5TUQbbqPiHxdBoOAmsChg2a";
      path = fetchZigArtifact {
        name = "iterm2_themes";
        url = "https://github.com/mbadolato/iTerm2-Color-Schemes/archive/e21d5ffd19605741d0e3e19d7c5a8c6c25648673.tar.gz";
        hash = "sha256-pyoGlKOWdZVbjGoxPP+CZ6zwil8O12gMOlzX0BJEfAc=";
      };
    }
    {
      name = "N-V-__8AAH0GaQC8a52s6vfIxg88OZgFgEW6DFxfSK4lX_l3";
      path = fetchZigArtifact {
        name = "imgui";
        url = "https://deps.files.ghostty.org/imgui-1220bc6b9daceaf7c8c60f3c3998058045ba0c5c5f48ae255ff97776d9cd8bfc6402.tar.gz";
        hash = "sha256-oF/QHgTPEat4Hig4fGIdLkIPHmBEyOJ6JeYD6pnveGA=";
      };
    }
    {
      name = "N-V-__8AAKLKpwC4H27Ps_0iL3bPkQb-z6ZVSrB-x_3EEkub";
      path = fetchZigArtifact {
        name = "freetype";
        url = "https://deps.files.ghostty.org/freetype-1220b81f6ecfb3fd222f76cf9106fecfa6554ab07ec7fdc4124b9bb063ae2adf969d.tar.gz";
        hash = "sha256-QnIB9dUVFnDQXB9bRb713aHy592XHvVPD+qqf/0quQw=";
      };
    }
    {
      name = "N-V-__8AAJrvXQCqAT8Mg9o_tk6m0yf5Fz-gCNEOKLyTSerD";
      path = fetchZigArtifact {
        name = "libpng";
        url = "https://deps.files.ghostty.org/libpng-1220aa013f0c83da3fb64ea6d327f9173fa008d10e28bc9349eac3463457723b1c66.tar.gz";
        hash = "sha256-/syVtGzwXo4/yKQUdQ4LparQDYnp/fF16U/wQcrxoDo=";
      };
    }
    {
      name = "N-V-__8AAB0eQwD-0MdOEBmz7intriBReIsIDNlukNVoNu6o";
      path = fetchZigArtifact {
        name = "zlib";
        url = "https://deps.files.ghostty.org/zlib-1220fed0c74e1019b3ee29edae2051788b080cd96e90d56836eea857b0b966742efb.tar.gz";
        hash = "sha256-F+iIY/NgBnKrSRgvIXKBtvxNPHYr3jYZNeQ2qVIU0Fw=";
      };
    }
    {
      name = "N-V-__8AAIrfdwARSa-zMmxWwFuwpXf1T3asIN7s5jqi9c1v";
      path = fetchZigArtifact {
        name = "fontconfig";
        url = "https://deps.files.ghostty.org/fontconfig-2.14.2.tar.gz";
        hash = "sha256-O6LdkhWHGKzsXKrxpxYEO1qgVcJ7CB2RSvPMtA3OilU=";
      };
    }
    {
      name = "N-V-__8AAG3RoQEyRC2Vw7Qoro5SYBf62IHn3HjqtNVY6aWK";
      path = fetchZigArtifact {
        name = "libxml2";
        url = "https://deps.files.ghostty.org/libxml2-2.11.5.tar.gz";
        hash = "sha256-bCgFni4+60K1tLFkieORamNGwQladP7jvGXNxdiaYhU=";
      };
    }
    {
      name = "N-V-__8AADTkRwBjUvVwTLOnV96QhN0J5Nyg7YzvnISe-Eax";
      path = fetchZigArtifact {
        name = "glfw";
        url = "https://github.com/glfw/glfw/archive/73948e6c0f15b1053cf74b7c4e6b04fd36e97e29.zip";
        hash = "sha256-k7wBKiQpgxBhqHRwSEgZjmfncltlGG8BgY3FhyycM5E=";
      };
    }
    {
      name = "N-V-__8AALiNBAA-_0gprYr92CjrMj1I5bqNu0TSJOnjFNSr";
      path = fetchZigArtifact {
        name = "gtk4_layer_shell";
        url = "https://deps.files.ghostty.org/gtk4-layer-shell-1.1.0.tar.gz";
        hash = "sha256-mChCgSYKXu9bT2OlXxbEv2p4ihAgptsDfssPcfozaYg=";
      };
    }
    {
      name = "N-V-__8AAKa0rgW4WI8QbJlq8QJJv6CSxvsvNfussVBe9Heg";
      path = fetchZigArtifact {
        name = "harfbuzz";
        url = "https://deps.files.ghostty.org/harfbuzz-1220b8588f106c996af10249bfa092c6fb2f35fbacb1505ef477a0b04a7dd1063122.tar.gz";
        hash = "sha256-nxygiYE7BZRK0c6MfgGCEwJtNdybq0gKIeuHaDg5ZVY=";
      };
    }
    {
      name = "N-V-__8AAGmZhABbsPJLfbqrh6JTHsXhY6qCaLAQyx25e0XE";
      path = fetchZigArtifact {
        name = "highway";
        url = "https://deps.files.ghostty.org/highway-66486a10623fa0d72fe91260f96c892e41aceb06.tar.gz";
        hash = "sha256-h9T4iT704I8iSXNgj/6/lCaKgTgLp5wS6IQZaMgKohI=";
      };
    }
    {
      name = "N-V-__8AADcZkgn4cMhTUpIz6mShCKyqqB-NBtf_S2bHaTC-";
      path = fetchZigArtifact {
        name = "gettext";
        url = "https://deps.files.ghostty.org/gettext-0.24.tar.gz";
        hash = "sha256-yRhQPVk9cNr0hE0XWhPYFq+stmfAb7oeydzVACwVGLc=";
      };
    }
    {
      name = "N-V-__8AAHjwMQDBXnLq3Q2QhaivE0kE2aD138vtX2Bq1g7c";
      path = fetchZigArtifact {
        name = "oniguruma";
        url = "https://deps.files.ghostty.org/oniguruma-1220c15e72eadd0d9085a8af134904d9a0f5dfcbed5f606ad60edc60ebeccd9706bb.tar.gz";
        hash = "sha256-ABqhIC54RI9MC/GkjHblVodrNvFtks4yB+zP1h2Z8qA=";
      };
    }
    {
      name = "N-V-__8AAPlZGwBEa-gxrcypGBZ2R8Bse4JYSfo_ul8i2jlG";
      path = fetchZigArtifact {
        name = "sentry";
        url = "https://deps.files.ghostty.org/sentry-1220446be831adcca918167647c06c7b825849fa3fba5f22da394667974537a9c77e.tar.gz";
        hash = "sha256-KsZJfMjWGo0xCT5HrduMmyxFsWsHBbszSoNbZCPDGN8=";
      };
    }
    {
      name = "N-V-__8AALw2uwF_03u4JRkZwRLc3Y9hakkYV7NKRR9-RIZJ";
      path = fetchZigArtifact {
        name = "breakpad";
        url = "https://deps.files.ghostty.org/breakpad-b99f444ba5f6b98cac261cbb391d8766b34a5918.tar.gz";
        hash = "sha256-bMqYlD0amQdmzvYQd8Ca/1k4Bj/heh7+EijlQSttatk=";
      };
    }
    {
      name = "N-V-__8AAHffAgDU0YQmynL8K35WzkcnMUmBVQHQ0jlcKpjH";
      path = fetchZigArtifact {
        name = "utfcpp";
        url = "https://deps.files.ghostty.org/utfcpp-1220d4d18426ca72fc2b7e56ce47273149815501d0d2395c2a98c726b31ba931e641.tar.gz";
        hash = "sha256-/8ZooxDndgfTk/PBizJxXyI9oerExNbgV5oR345rWc8=";
      };
    }
    {
      name = "N-V-__8AAAzZywE3s51XfsLbP9eyEw57ae9swYB9aGB6fCMs";
      path = fetchZigArtifact {
        name = "wuffs";
        url = "https://deps.files.ghostty.org/wuffs-122037b39d577ec2db3fd7b2130e7b69ef6cc1807d68607a7c232c958315d381b5cd.tar.gz";
        hash = "sha256-nkzSCr6W5sTG7enDBXEIhgEm574uLD41UVR2wlC+HBM=";
      };
    }
    {
      name = "N-V-__8AADYiAAB_80AWnH1AxXC0tql9thT-R-DYO1gBqTLc";
      path = fetchZigArtifact {
        name = "pixels";
        url = "https://deps.files.ghostty.org/pixels-12207ff340169c7d40c570b4b6a97db614fe47e0d83b5801a932dcd44917424c8806.tar.gz";
        hash = "sha256-Veg7FtCRCCUCvxSb9FfzH0IJLFmCZQ4/+657SIcb8Ro=";
      };
    }
    {
      name = "N-V-__8AABzkUgISeKGgXAzgtutgJsZc0-kkeqBBscJgMkvy";
      path = fetchZigArtifact {
        name = "glslang";
        url = "https://deps.files.ghostty.org/glslang-12201278a1a05c0ce0b6eb6026c65cd3e9247aa041b1c260324bf29cee559dd23ba1.tar.gz";
        hash = "sha256-FKLtu1Ccs+UamlPj9eQ12/WXFgS0uDPmPmB26MCpl7U=";
      };
    }
    {
      name = "N-V-__8AANb6pwD7O1WG6L5nvD_rNMvnSc9Cpg1ijSlTYywv";
      path = fetchZigArtifact {
        name = "spirv_cross";
        url = "https://deps.files.ghostty.org/spirv_cross-1220fb3b5586e8be67bc3feb34cbe749cf42a60d628d2953632c2f8141302748c8da.tar.gz";
        hash = "sha256-tStvz8Ref6abHwahNiwVVHNETizAmZVVaxVsU7pmV+M=";
      };
    }
  ]
