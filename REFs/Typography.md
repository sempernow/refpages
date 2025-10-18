
# [Typography](https://en.wikipedia.org/wiki/Typography "@ Wikipedia") | [Lingo](#typographical-terms "below") | [Google Fonts](https://fonts.google.com/ "@ fonts.google.com") | [Font Library](https://fontlibrary.org/ "@ FontLibrary.org")

## [UTF-8 Unicode Blocks](https://en.wikipedia.org/wiki/Unicode_block "@ Wikipedia") | [Code Point Tables](https://www.utf8-chartable.de/unicode-utf8-table.pl "@ utf8-CharTable.de") | [Browser Test](https://www.fileformat.info/info/unicode/block/index.htm "@ FileFormat.info [+SVG]") | [A&ndash;Z Index](https://www.fileformat.info/info/unicode/char/a.htm "@ FileFormat.info [+SVG]") | [Quackit.com](https://www.quackit.com/character_sets/unicode/ "List of Unicode Characters")
- [Basic Latin U(`0000–007F`)](https://en.wikipedia.org/wiki/Basic_Latin_%28Unicode_block%29 "Wikipedia")
- [Latin-1 Supplement U(`0080–00FF`)](https://en.wikipedia.org/wiki/Latin-1_Supplement_%28Unicode_block%29 "Wikipedia")
- [Latin Extended-A U(`0100–017F`)](https://en.wikipedia.org/wiki/Latin_Extended-A "Wikipedia")
- [Greek and Coptic U(`U+0370-03FF`)](https://en.wikipedia.org/wiki/Greek_and_Coptic "Wikipedia")
- [Currency Symbols U(`20A0–20CF`)](https://en.wikipedia.org/wiki/Currency_Symbols_%28Unicode_block%29 "Wikipedia")
- [Letterlike Symbols U(2100-214F)](https://www.utf8-chartable.de/unicode-utf8-table.pl "utf8-chartable.de")
- [Miscellaneous Technical U(`2300–23FF`)](https://en.wikipedia.org/wiki/Miscellaneous_Technical "Wikipedia")
- [Geometric Shapes U(`23A0–25FF`)](https://en.wikipedia.org/wiki/Geometric_Shapes "Wikipedia")
- [Dingbats U(`2700–27BF`)](https://en.wikipedia.org/wiki/Dingbat#Dingbats_Unicode_block "Wikipedia")
- [Mathematical Alphanumeric Symbols U(`U+1D400-1D7FF`)](https://en.wikipedia.org/wiki/Mathematical_Alphanumeric_Symbols "Wikipedia") | [@ quackit.com](https://www.quackit.com/character_sets/unicode/versions/unicode_9.0.0/mathematical_alphanumeric_symbols_unicode_character_codes.cfm)
- [Transport and Map Symbols U(`1F680–1F6FF`)](https://en.wikipedia.org/wiki/Transport_and_Map_Symbols "Wikipedia [Includes many emojis]")
- [Emoticons U(`1F600–1F64F`)](https://en.wikipedia.org/wiki/Emoticons_%28Unicode_block%29 "Wikipedia") &hellip; are __not__ emojis, but adopted many (2008/2010) into this code block.
- [Emoji](https://en.wikipedia.org/wiki/Emoji "Wikipedia") | [Unicode Emoji Characters](https://www.quackit.com/character_sets/emoji/ "quackit.com") | [Unicode Version 10.0](https://emojipedia.org/unicode-10.0/ "@ Emojipedia.com") | [Full Emoji List](https://unicode.org/emoji/charts/full-emoji-list.html "@ Unicode.org")
    - Emojis are _pictographs_, whereas emoticons are _typographs_. Emoji [span several Unicode Code Blocks](https://en.wikipedia.org/wiki/Emoji#Unicode_blocks "Emoji/Unicode @ Wikipedia"); their renderings vary widely per platform; originated in Japan (1997) for use with SMS; popularized across West when several mobile operators began including them (2010).

### [Unicode](https://en.wikipedia.org/wiki/Unicode "wikipedia.org") is a __character-set__
- Unicode Charset :: `char`&nbsp;<&mdash;>&nbsp;`int`    
A _glyph_ maps to a _Code Point_.

### [UTF-8](https://en.wikipedia.org/wiki/UTF-8 "wikipedia.org") is an __encoding__  
- UTF-8 Encoding ::  `int`&nbsp;<&mdash;>&nbsp;`bin`    
A _Code Point_ maps to _byte(s)_.  
  - One Unicode glyph is __1 to 4 bytes__ in `UTF-8`; this encoding allows for more than __a million glyphs__.
- UTF-8 is *the* universally accepted encoding for all Unicode Charsets.    
    - [It is backward compatible with ASCII](https://nedbatchelder.com/text/unipain.html "'Pragmatic Unicode' 2012")
    - [HTML5 UTF-8 Character Codes](https://w3schools.com/charsets/ref_html_utf8.asp "HTML Unicode/UTF-8 Reference @ w3schools.com")  

### Unicode __Code Point__ <a name="code-point">&nbsp;</a>

- A namespaced ___integer___ defining a single Unicode ___character___, a.k.a. ___glyph___, a.k.a. ___rune___, a.k.a., ___symbol___. The integer is most often referenced by its hexidecimal representation preceeded by "`U+`". For example, the popular "🚀" glyph is defined under __Unicode__ as:   

    |                  |           |
    |------------------|-----------|
    |Character:        |🚀        |
    |Code Point:&nbsp; |`U+1F680`  |
    |Name:             |`ROCKET`   |
    |Block:            |`Transport and Map Symbols`|

- Convert between Unicode and __Bytes__ (Encode/Decode)   
  - @ [Python](https://docs.python.org/3/howto/unicode.html "docs.python.org/3/howto/"):   
  `.encode()`&nbsp;&mdash;&nbsp;Unicode ___to bytes___  
  `.decode()`&nbsp;&mdash;&nbsp;bytes ___to Unicode___  
  - @ [Golang](https://golang.org/pkg/unicode/utf8/#example_EncodeRune "golang.org/pkg/unicode/utf8"):   
  `utf8.EncodeRune(p []byte, r rune) int`   
    &nbsp;&mdash;&nbsp;Unicode ___to bytes___   
  `utf8.DecodeRune(p []byte) (r rune, size int)`   
    &nbsp;&mdash;&nbsp;bytes ___to Unicode___
- Convert between Unicode and __HTML Entity__/__Symbol__ using the __hex__ representation of the Unicode Code Point: "`U+`"&nbsp;<&mdash;>&nbsp;"`&#`", "`0`|`00`"&nbsp;<&mdash;>&nbsp;"`x`", and append "`;`" . E.g.,  

    - `U+00A7` <&mdash;> `&#xA7;`    

### Disambiguation  

A Code Point is a ___unique identifier___, and one that is ___unambiguous___, always and everywhere, unlike all other relevant typographical terms.

>In the __context__ of Unicode/UTF-8 (`character-set`/`encoding`), all references to the visually rendered (character, glyph, rune, symbol) are __synonymous__. However, in the context of _typefaces_, such references may differ. The whole purpose of a typeface is to render its set of characters distinctly from those of others, with further variations amongst its own `font-family` (light, bold, condensed, &hellip;). So, in such contexts, a glyph, character, rune, symbol or whatever, _references a particular design and/or rendering_ of such. That is, ___for any one Code Point___, e.g., "A", "`LATIN CAPITAL LETTER A` (`U+0041`)", ___there are many glyphs___, one from each font, each rendering distinctly by design (normal, italics, extended, &hellip;). In such a context, the distinct renderings are often referred to as _glyphs_, while the (unique) Code Point is often referred to as _the  character_ or _the symbol_. This ambiguous lingo is pervasive across the whole of typography. See [Typographical&nbsp;Terms](#typographical-terms "below").

### [HTML Entities](https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references#Character_entity_references_in_HTML "@ Wikipedia") 

Every [Unicode Code Point](#code-point "above") converts to its HTML entity for browser rendering. An _HTML entity_, a.k.a., _HTML Symbol_, has several __representations__, all of which are equivalent; ___hexidecimal___ (`&#x*;`), ___decimal___ (`&#*;`), and &mdash; for some &mdash; ___named___ (`&NAME;`). Note that an HTML Entity _Name_ is __typically not__ its Unicode Code Point _Name_. For example, the _ellipsis_ symbol (&hellip;) is Unicode Code Point `U+2026` and Unicode Name "`HORIZONTAL ELLIPSIS`". That maps to HTML Entity `&#x2026;` (hex), `&#8230;` (dec), `&hellip;` (named). 

```
symbol   code     hex       dec       Unicode name

A        U+0041   &#x41;    &#65;     LATIN CAPITAL LETTER A
§        U+00A7   &#xA7;    &#167;    SECTION SIGN
©        U+00A9   &#xa9;    &#169;    COPYRIGHT SIGN
֍        U+058D   &#x58D;   &#1421;   RIGHT-FACING ARMENIAN ETERNITY SIGN
ᛟ        U+16DF   &#x16DF;  &#5855;   RUNIC LETTER OTHALAN ETHEL O 
☧        U+2627   &#x2627;  &#9767;   CHI RHO
☩       U+2629   &#x2629;  &#9769;   CROSS OF JERUSALEM
⋮        U+22EE   &#x22EE;  &#8942;   VERTICAL ELLIPSIS
︙       U+FE19   &#xfe19;  &#65049;  PRESENTATION FORM FOR VERTICAL HORIZONTAL ELLIPSIS
☰       U+2630   &#x2630;  &#9776;   TRIGRAM FOR HEAVEN
✕       U+2715   &#x2715;  &#10005;  MULTIPLICATION X
```

- HEX/DEC render identically (per browser) regardless of representation:

    HEX:<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&#x41;|&#xa7;|&#xa9;|&#x58d;|&#x16df;|&#x2627;|&#x2629;|&#x22EE;|&#xFE19;|&#x2630;|&#x2715; &hellip; &#x10348;|&#xF92B;|&#x103BF;|&#x130F2;|&#x2ce9;</span>

    DEC:<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&#x41;|&#167;|&#169;|&#1421;|&#5855;|&#9767;|&#9769;|&#8942;|&#65049;|&#9776;|&#10005; &hellip; &#x10348;|&#63787;|&#66495;|&#78066;|&#11497;</span>  


-  ___Non-breaking space___: `&nbsp;` (foo&nbsp;bar)

-  ___Non-breaking hyphen___: `&#x2011;` (foo&#x2011;bar)

- Add emphasis/color to prior glyph : `\ufe0f`

- [Animals](https://graphemica.com/characters/tags/animal "animal @ graphemica.com")

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&#x1f410;|&#x1F40f;|&#x1F413;|&#x1f418;|&#x1f419;|&#x1F41d;|&#x1F41e;|&#x1F427;|&#x1F428;|&#x1F42f;|&#x1F991;|&#x1F422;|&#x1f42A;|&#x1F42b;|&#x1F42c;|&#x1f437;|&#x1f409;|&#x1F432;|&#x1f433;|&#x1F438;|&#x1F989;|&#x1F987;|&#x1F43a;|&#x1F98A;|&#x1F43b;|&#x1F43c;|&#x1F98D;|&#x1F996;
</span>  

&nbsp;

- Various : Declared as glyph

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">
…|⋮|︙|•|●|–|—|™|®|©|±|°|¹|²|³|¼|½|¾|÷|×|₽|€|¥|£|¢|¤|♻|⚐|⚑|✪|❤
☢|☣|☠|¦|¶|§|†|‡|ß|µ|Ø|ƒ|Δ|☡|☈|☧|☩|✚|☨|☦|☓|♰|♱|✖||☘||웃|🡸|🡺|➔
</span>  

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">
ℹ️|⚠️|✅|⌛|🚀|🚧|🛠️|🔧|🔍|🧪|👈|⚡|❌|💡|🔒
📊|📈|🧩|📦|🥇|✨️|🔚 
</span>  

&nbsp;

- Various : Declared code point

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&#x2731;|&#x229b;|&#x2725;|&#x2732;|&#x274A;|&#x1F7BE;|&#x1F7BF;|&#x2055;|&#x03FA;|&#x03FE;|&#x0950;|&#x26C9;|&#x1F130;|&#x1F145;</span>

<!-- WORLD MAP 
<div style="font-size:5em;">&#x1F5FA;</div>
-->

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&#x2714;|&#x2716;|&#x2718;|&#x271a;|&#x275d;|&#x275e;|&#x2760;|&#x1f676;|&#x1f677;|&#x1f678;|&#x2756;|&#x2764;|&#x2776;|&#x2777;|&#x277f;</span>

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">
&hellip;|&#x2761;|&#x00B6;|&#x204b;|&#x2e3f;|&#x203b;|&#x2058;|&#x205B;|&#x205C;|&#x2116;|&#x20bf;|&#x2022;|&#x2120;|&#x2122;</span>

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&bull;|&#x25cf;|&#x26aa;|&#x2b24;|&#xc6c3;|&#x2117;|&#x2312;|&#x2660;|&#x2663;|&#x2665;|&#x2666;</span>

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">
&#x1F6D2;|&#x1f383;|&#x1f480;|&#x1f3c1;|&#x1f600;|&#x1f922;|&#x1f44c;|&#x1f961;|&#x1f3e0;|&#x1f680;|&#x1F916;|&#x1F921;</span>   

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&#x1F321;|&#x26c8;|&#x1f32a;|&#x2603;|&#x2744;|&#x1f30c;|&#x26a1;|&#x1f947;|&#x1f6b9;|&#x1f6ba;|&#x1f6ae;</span>  

<span style="font-size:1.5em;line-height:1.2em;margin-left:2em;">&#x1f4bb;|&#x1f4f1; ƿ૯ωძɿ૯ƿɿ૯</span>  

## Typographic Terms <a name="typographical-terms">&nbsp;</a>

- Typesetting &mdash; The composition of text by means of arranging physical types, or the digital equivalent, e.g., [TeX](https://en.wikipedia.org/wiki/TeX "@ Wikipedia") typesetting system. 
- [LaTex](https://en.wikipedia.org/wiki/LaTeX "@ Wikipedia") &mdash; Document preparation system (1983) including its own markup tagging conventions; widely used in acadamia.
- Language &mdash; Character set; alphabetic writing system:  
    - LGC &mdash; Latin/Greek/Cyrillic
    - CJK &mdash; Chinese/Japanese/Korean  
- Typeface <a name="typeface">&nbsp;</a> &mdash; One font family (see [Typeface Classifications](#typeface-classifications "below")); may comprise many fonts of varying style & weight; -thin, -medium, -bold, -bold-italic, -black, -condensed, -expanded-light, &hellip; 
- Font &mdash; One complete set of unique glyphs. One or more constitute a font family (typeface); earliest digital fonts were designed as bitmaps for rendering at a specified pixel size, but today virtually all are of vectors (see [Outline Font](#vector-font "below")).
    - Extended (meaning per context): 
        1. Larger character set(s); more glyphs; typically declared per Unicode table(s), e.g., "Latin-1 Sup", "Latin Extended-A", "Currency Symbols", &hellip;  
        2. A synonym for an _expanded_ font; wider glyphs (horizontally stretched) especially relative to its font family (typeface).  
    - Subsetting  &mdash; Rebuilding/converting a font per some subset of its character set; typically per character type or Unicode table(s); to reduce TX/RX file size.
- Glyph &mdash; One character/rune/symbol (visual) rendering; an elemental symbol; designed and rendered per either vector or bitmap (per font); a font is a set of glyphs; every Unicode character (glyph/rune/symbol) has a unique Name and Code Point (namespaced integer).
    - X-height &mdash; Distance between the baseline and the mean line of a glyph. 
    - Kerning &mdash; Mortising; adjusting spacing between characters of a proportional font, e.g., "Wa", "AV"; designed, per-font effect(s). 
    - Ligature &mdash; Joining adjacent chars into 1 glyph, e.g., "fl". Note the ampersand, "&amp;", is a ligature of Latin "et"; designed, per-font effect(s). 
    - [Diacritic](https://en.wikipedia.org/wiki/Diacritic "@ Wikipedia") (Diacritic Mark, Diacritical Point, or Diacritical Sign) &mdash; Accent symbol(s) added to the basic glyph to compose certain letters of a character set. Many glyphs of the Cyrillic character set include such symbols. 
- [Bitmap/Pixel/Raster Font](https://en.wikipedia.org/wiki/Computer_font#Bitmap_fonts "@ Wikipedia") &mdash; Defines each of its glyphs by a matrix of pixel declarations (describing every pixel thereof); designed and rendered to its specified pixel dimensions, exclusively; faster and simpler to render than vector fonts, but does not scale; degrades if rendered to any font size (`px`) other than that of its design. Older technology than Outline Font.
- [Outline Font](https://en.wikipedia.org/wiki/Computer_font#Outline_fonts "@ Wikipedia") (Vector Font) <a name="vector-font"></a> &mdash; Computer font implemented using vector graphics; an image (glyph) consisting of lines and curves ([Bézier splines](https://en.wikipedia.org/wiki/B%C3%A9zier_curve "@ Wikipedia")) defining only its _boundary_ (outline). 
    - (Adobe) PostScript  &mdash; Computer language for creating vector graphics, created by Adobe. The universal standard for Outline Fonts:
        - PostScript Type 1
        - PostScript Type 3
        - TrueType (TTF; `.ttf`)
            - Developed by Apple & Microsoft (1980s); competitor to Adobe Type 1 fonts used in PostScript.  
        - OpenType (OTF; `.otf`)
            - Successor to TrueType; developed by Microsoft & Adobe; now a standard; (Web) Open Font Format (OFF/WOFF).
            - [Embedded Open Type](https://en.wikipedia.org/wiki/Embedded_OpenType "@ Wikipedia") (EOT; `.eot`) &mdash; Compressed form of OTF; designed and implemented by and for Microsoft (for Internet Explorer). 
    - [Web Open Font Format](https://en.wikipedia.org/wiki/Web_Open_Font_Format "@ Wikipedia") (WOFF; `.woff` &amp; `.woff2`) &mdash; Compressed format of TTF (`.ttf`) or OTF (`.otf`); the defacto standard for web-served, browser-rendered fonts:
        - WOFF 1.0 (`.woff`) is [supported by most](https://en.wikipedia.org/wiki/Web_Open_Font_Format#Vendor_support "@ Wikipedia") modern browsers; Chrome(v36+), Firefox(v35+), and Opera(v26+); MIME Type `font/woff`.  
        - WOFF 2.0 (`.woff2`) compression (~ 30% smaller) is not as widely supported; MIME Type `font/woff2`.
    - [SVG Fonts](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/SVG_fonts "@ MDN") &mdash; Font description per [SVG](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics "@ Wikipedia") `<font>` element; rejected by most browser vendors; _"&hellip; not meant for compatibility with other formats &hellip; currently [2019] supported only in Safari and Android Browser &hellip; removed from Chrome 38 (and Opera 25) &hellip; Firefox has postponed its implementation indefinitely to concentrate on WOFF"_
- ClearType &mdash; Sub-pixel font rendering technology by Microsoft and utilized in Windows OS; improves legibility (important); sacrifices color accuracy (less important).  
- [Typeface](#typeface "above") Classifications <a name="typeface-classifications">&nbsp;</a>
    - Buckets of ambiguous notions; multiple contradictory meanings, even within the same context. E.g., both 'Humanist' and 'Realist' may refer to either serif or sans-serif; 'Old Style' is serif, whereas 'Old English' is Blackletter; 'Gothic' is sans-serif, whereas 'Gothic Script' is Blackletter; 'Geometric' is sans-serif, but may reference a certain subset of typefaces therein. Here's the _hellscape_:
    - Roman: An ambiguous term having different meanings per context: 
        - Typeface Category: Serif  (vs. Blackletter or Gaelic/Irish)   
        - Style: normal (vs. italic).  
        - Weight: normal (vs. bold).  
        - Variety of Cyrillic script (vs. Slavonic).  
    - Serif Categories:  
        - Roman  
        - Old Style (Humanist)  
        - Transitional (Baroque)  
        - Modern (Didone)  
        - Slab (Egyptian, Realist)  
    - Sans-serif Categories:  
        - Grotesque (Grotesk{German})   
        - Gothic  
        - Realist (if modern)  
        - Neo-grotesque  
        - Geometric  
        - Humanist  
    - Blackletter: A class of typeface; mimics handwriting; scripts of old (1100–1800) W. Europe; Antiqua, Textura, Gothic Script, Gothic Minuscule, Old English; 
        - Blackletter categories:
            - [Fraktur](https://en.wikipedia.org/wiki/Fraktur "@ Wikipedia")
            - [Kurrentschrift](https://en.wikipedia.org/wiki/Kurrent "@ Wikipedia")
            - Sütterlin
    - [Vox-ATypI](https://en.wikipedia.org/wiki/Vox-ATypI_classification "@ Wikipedia") (Association Typographique Internationale) &mdash; An older (1962), defunct (2010), typeface classification scheme:  
        - Classicals        
            - Humanist, Garalde, Transitional  
        - Moderns           
            - Didone, Mechanistic, Lineal, Grotesque, Neo-grotesque,Geometric,Humanist   
        - Calligraphics     
            - Glyphic, Script, Graphic, Blackletter, Gaeilic  
        - Non-Latin/Exotic  
            - Greek, Cyrillic, Hebrew, Arabic, Chinese  

## Typographic Properties :: [Material Design](https://material.io/design/typography/understanding-typography.html "material.io")

## Grammatical Usage

### Hyphen / En dash / Em dash

-  __Hyphen__  (-)
    - As a __compound modifier__ _before_ a noun:  
     _dog-friendly apartments_
    - As a __separator for prefix__, __suffix__, __compound number__, or __line-break__:  
     _mid-October_, _president-elect_, _forty-five_, _inter-_   
     _national_  
    - As a __field separator__:   
     _1-800-123-4567_
     
-  __En dash__  (&ndash;)
    - As a __range separator__:  
    _pages 32&ndash;37_, _Ja&ndash;Li_,  _6:30&ndash;8:00_,  _1995&ndash;_

-  __Em dash__ (&mdash;)
    - In place of __parentheses__, perhaps as a second parenthetical:   
    _Start main notion &mdash; inject parenthetical notion &mdash; continue with main (perhaps containing this too) notion._ 
        - Apply the em dash with or without spaces, but do so consistently. 
    - In place of a __colon__:   
    _The verdict was in &mdash; guilty._
    - To indicate some kind of __lexical distinction__:   
    _&hellip; label, input, button &mdash; they're all HTML Form elements._  
    _That's wizardry &mdash; peddling a perfect inversion of reality_.  
    - Use __2 consecutively__ to indicate __missing letter__(s):   
    _The mob was chanting something like ad&mdash;&mdash;n [addiction?]._   
    - Use __3 consecutively__ to indicate __missing word__(s):  
    _They &mdash;&mdash;&mdash; before, and then &mdash;&mdash;&mdash; drug store._ 

    > The Em dash is ___less formal___ than its alternatives; less prevalent in business and academia; more so in consumer-facing prose. ___Especially useful for___ depicting ___verbal dialogue___.

### Round/Square [Brackets](https://www.lexico.com/en/grammar/parentheses-and-brackets "lexico.com") 

- __Round brackets__, a.k.a. parentheses, are mainly used to separate off information that isn’t essential to the meaning of the rest of the sentence:
    - _Mount Denali (in Alaska) is the highest mountain in North America._  
    _There are several books on the subject (see page 120)._  

- __Square brackets__, a.k.a. braces, are mainly used to enclose words added by someone other than the original writer or speaker, typically in order to clarify the situation:
    - _He [the cousin] left the house long before that happened._


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

