# [WebP](https://developers.google.com/speed/webp/docs/cwebp "@ developers.google.com") : [`cwebp`](https://developers.google.com/speed/webp/docs/cwebp "@ developers.google.com") | [Download the binaries](https://developers.google.com/speed/webp/download "@ developers.google.com")

Google released a suite of WebP utilities.

## Convert to WebP

```bash
# @ PNG w/ alpha channel
cwebp ${fname}.png -lossless -exact -o ${fname}.webp
# @ PNG or JPG (sans alpha)
cwebp ${fname}.jpg -o ${fname}.webp
# +Explicit quality 
cwebp -q 85 ...
# +Resize; proportionally if either is 0
cwebp -resize $width $height ...
# +Crop; start @ top-left corner position (x_start, y_start)
cwebp -crop $x_start $y_start $width $height ...
```

## Decode from WebP to &hellip;

```bash
dwebp ${fname}.webp -o ${fname}.png
```

### &nbsp;

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

