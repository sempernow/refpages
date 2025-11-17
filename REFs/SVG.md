# SVG 

## Typography per SVG [@ `text.svg`](text.svg "text.svg")

## Adobe Illustrator (Ai) @ `Adobe.Ai` ([MD](Adobe.Ai.html "@ browser"))   

## [InkScape](https://inkscape.org/learn/tutorials/ "inkscape.org") (PortableApps)

- `Save as ...` > `Optimized SVG (*.svg)`

## Minify SVG file : [`svgo`](https://github.com/svg/svgo "@ GitHub")

```bash
npx svgo SOURCE.svg  # Overwrites source
npx svgo SOURCE.svg -o OUT.svg
```

## HTML/CSS

## Self closing tags such as `path`, `polygon`, etc. do ___not validate___ as HTML5; `<path ... />`

Some modern browsers fix such invalid tags on-the-fly; some don't.

>Reading the HTML5 specification, which is [the typical IT hellscape of useless verbosity](https://html.spec.whatwg.org/multipage/syntax.html#void-elements), one would reasonably conclude that self-closing `path` tags are valid. It explicitly references the "SVG Namespace" tags as "Foreign Elements" and those listed here that don't validate are also "Void Elements". And those are the two categories specified as valid if self-closing. But no, apparently. 

>We'll have to wait another half-century before IT specs are formatted as key-value pairs, as engineers figured out centuries ago. (Actual engineers, not "IT engineer"s.)

 Convert to valid &hellip; 

```html 
<path ...></path>
``` 

## `viewBox` : Modify Alignment/Position/Size 

>### tl;dr 
>Normalize to Zero-offest Viewbox (`viewBox="0 0 w h"`), assuring dynamic ___resize without clipping___.  

### Normalize @ Ai &hellip;

>`File > Export > Export for Screens`  
> `> Select: All`  

SVG `viewBox` attribute sets the render boundary and placement therein. 

- [@ `viewBox="x-min y-min width height"`](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/viewBox "@ MDN")

Adobe Illustrator (__Ai__) will add/modify it as needed per processing &hellip; 

- Crop:   
    - `Object > Artboards > Fit to Artwork Bounds`  
- Transform:   
    - `Object > Transform >` `Move`, `Rotate`, ` Scale`, &hellip;
        - Operates on selected object(s) only; use mouse.

While sizing and placement are overridden per CSS, it is useful to scale an SVG to, say, `1000px` or more, for fine-grained control/manipulation (coordinates), and so that any subsequent bitmap image rendering (e.g., PNG) will be of high quality. Though Ai also offers [scaled bitmap image conversion/export](#scaled_png) too.

Style per CSS. For image attributes per se (`fill`, `height`, `width`, &hellip;) style _the_ "`<svg>`" _element itself_; perhaps even inlining the dimensions, if static and otherwise apropos, just to be safe. Conversely, style its _container_ regarding CSS positioning, `display`, and such _box-model_ properties.

## [@ `viewBox="x-min y-min width height"`](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/viewBox "@ MDN")

>Note that `viewBox` parameters do __not__ change the graphic (size or proportions) itself, but only that (and positioning) _relative to the view_; to the bounds (box) of the view.

1. Open in __Ai__
    - Scale (set its native size; `~ 1000px`):   
        - `Objects > Transform > Scale` (`%` is the only option).  
    - Reset `viewBox`: 
        - `Objects > Artboards > Fit to Artwork bounds`.   
    - Export as SVG: 
        - `File > Export > Export for Screens`. 
            - If  `Select: Full Document`, then any _relative positioning information is lost_. It saves as original filename, or as "`Untitled-1.svg`" if new.
            - If `Select: All`, then positioning and size _relative to `viewBox`_ is _preserved and normalized_. It saves as "`Artboard 1.svg`".   
            - At this point in the process, either selection is okay since we just reset the `viewBox`, so there is no relative positioning information to preserve. 
2. Open in text editor, and manually adjust `viewBox` parameters __to modify the location and size__ of the graphic _relative to the view box_, adjust `width` and `height`. Adjust the offsets (`x-min`, `y-min`) to re-center it.  
    - E.g., if the graphic fills the viewbox "`0 0 500 500`" edge to edge, then "`-15 -15 530 530`" inserts `15px` of emptiness around it, keeping it centered. 
    - Do not modify the Artboard (@ Ai) after doing so, else (all changes to) _relative positioning will be lost_.
3. Open in Ai, and again save: 
    - `File > Export > Export for Screens > Select: All`. (__Not__ `Full Document`.) 
    - Saving the Artboard in this manner is a _powerful option/tool_ in that it ___normalizes all paths___ such that `viewBox` ___offsets are reset to zero___, while ___preserving relative scale(s) and position(s) of all object(s)___ within the `viewBox`. 
4. Delete all cruft from the SVG file. It's okay to delete grouping elements (`g`), and the `id` and `class` attributes/values too. 

## SVG-Font Glyph to SVG 

SVG-font glyphs do not render in browsers if used directly in an HTML `svg` element. They must first be [converted](https://helpfulsheep.com/2015-03-25-converting-svg-fonts-to-svg/ "'Converting SVG fonts to... SVG' 2015 @ helpfulsheep.com") from `glyph` to `path`, and then normalized, all per SVG specs:

1. Manually, [or by script](https://helpfulsheep.com/2015-03-25-converting-svg-fonts-to-svg/ "'Converting SVG fonts to... SVG' 2015 @ helpfulsheep.com"), map the SVG-font `glyph` to `path`, which is as simple as stripping out everything but for the `d=...` element, and swapping tags; "`<glyph>`" to "`<path>`". The "`d=...`" values-string is preserved (unchanged). See the example below.
2. Crop @ Ai:
    - `Object > Artboards > Fit to Artwork Bounds`
3. Transform @ Ai:
    - `Object > Transform > Move`, `Rotate`, ` Scale`, &hellip;
        - Operates on selected object(s) only; use mouse.
4. <a name="scaled_png"></a>Export @ Ai:
    - `File > Export > Export for Screens > Full Document`
        - Optionally, additional exports of various (scaled) bitmap image file(s), e.g., PNG, are available here.
5. Manually normalize by adding `transform` to path; `scale` (vertical flip) and `translate` (to re-center). This is because an SVG-font `glyph` is _upside down_ relative to an SVG `path`.
6. Manually delete unnecessary `svg` attributes/values (`id`, `title`, &hellip;).

### Example: "`웃`"

Unicode glyph `'HANGUL SYLLABLE US'` (`U+C6C3`) is plucked from [Malgun Gothic](https://en.wikipedia.org/wiki/Malgun_Gothic "@ Wikipedia") (`malgun.ttf`), which is a Hangul Symbol font. The TTF is first converted (online) to SVG font (`glyph`), and then (per Ai) to SVG (`path`).

@ SVG font (`glyph`)

```xml
<svg xmlns="http://www.w3.org/2000/svg" version="1.1">
    <glyph
         glyph-name="uniC6C3"
         unicode="웃"
         vert-adv-y="2176"
         d="M1024 1063q-298 0 -456 92.5t-158 ... -295.5t475.5 -158.5z" />
</svg>
```

@ SVG (`path`)

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1500 1500">
    <path 
        d="M1024 1063q-298 0 -456 92.5t-158 ... -295.5t475.5 -158.5z" />
</svg>
```

@ Transformed SVG (`path`), after cropped to artboard and exported per Ai.

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1790 1886">
    <path 
        transform="scale(1, -1) translate(0, -1886)" 
        d="M895,1200q-298,0-456... ,206.5-295.5T1651,127Z"/>
</svg>
```

## PNG to SVG 

#### @ Adobe Illustrator (Ai)

- Convert from bitmap to vector graphic: 
    - `Window > Image Trace` 

- Crop background (`Artboard`) to image (`Object`): 
    - `Object > Artboards > Fit to Selected Art`

- Save as SVG file:
    - `File > Export > Export for Screens` 


## Unicode Glyph per SVG file

[&#x2715;](https://www.fileformat.info/info/unicode/char/2715/index.htm "'MULTIPLICATION X' U+2715") | [&#x2630;](http://www.fileformat.info/info/unicode/char/002630/index.htm "'TRIGRAM FOR HEAVEN' U+2630")

### [@ `fileformat.info`](https://www.fileformat.info/info/unicode/char/a.htm "A to Z Index of Unicode Characters") 

- Find and select the Unicode glyph
- Save the Unicode glyph as SVG file  
    - The hypertext link @ "Outline (as SVG file)".

#### @ Adobe Illustrator (Ai)

- @ Ai Menu
    - Crop &amp; add `viewport` @ `Object` menu:   
    `> Artboards `    
    `> Fit to Artwork Bounds `  

    - Save as SVG @ `File` menu:     
    `> Export > Export for Screens... `    
    `> Full Document `    
    `> Export Artboard`

Note on save as `Select: Full Document` vs `Select: All`; the latter (`All`) preserves positioning information relative to `viewBox`, and saves as `Artboard 1.svg`. 

#### @ Text Editor, open the SVG file:

- Remove all the cruft; `id`, `data-name`, `defs`, `style`, `title`, `class` .  
- Keep only `xmlns`, `viewbox` and `path` .

Original 

```xml
<svg 
    id="Layer_1" 
    data-name="Layer 1" 
    xmlns="http://www.w3.org/2000/svg" 
    viewBox="0 0 220 185.1"
>
    <defs>
        <style>
            .cls-1{stroke:#000;}
        </style>
    </defs>
    <title>FNAME</title>
    <path class="cls-1" d="..."/>
</svg>
```

Final 

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 220 185.1">
    <path d="..."/>
</svg>
```

#### @ HTML 

- Supported @ `img` and `svg` tags.

    ```html
    <svg class="svgtest">...</svg>

    <img class="svgtest" src="images/svg/tfh.svg" alt="TRIGRAM FOR HEAVEN">
    ```

#### @ CSS 

- SVG file path is _relative to css file_.

    ```css
    svg, 
    .svgtest svg {
        background-image: url(../images/svg/tfh.svg);   
        width: 48px;
        height: 48px; 
    }
    ```

- Use `currentColor`, a CSS keyword, to __inherit color__ from parent.

    ```css
    button svg {
        fill: currentColor;
    }
    ```

- Useable @ CSS pseudo-class(es)

    ```css
    button svg:hover {
        fill: var(--color-anchor-link);
    }
    ```

## Add Dropshadow (properly)

>A common method for adding dropshadow to an SVG graphic
>is by embedding a graphics file of the desired effect, and applying it as an overlay. 
>However, the resulting SVG file is huge (100x). 

Instead, **embed CSS in the SVG** to add the effect  
as just another vector-graphics object:

```svg
<svg version="1.1" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <style>
        .dropshadow-1 {
            filter: drop-shadow(7px 7px 6px rgb(0 0 0 / 0.3));
        }
        </style>
    </defs>
    <g class="dropshadow-1">
         ...
    </g>
</svg>

```
- See [svg-dropshadow-css.svg](svg-dropshadow-css.svg)

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (MD | HTML)

([MD](___.html "@ browser"))   


# Bookmark

- Reference
[Foo](#foo)
- Target
<a name="foo"></a>

-->

