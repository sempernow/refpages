# [Regular Expression](https://en.wikipedia.org/wiki/Regular_expression "Wikipedia")

## [RegularExpressions101](https://regex101.com/r/wzEUei/2 "regex101.com")

## [Regex Tester - Golang](https://regex-golang.appspot.com/assets/html/index.html "regex-golang.appspot.com")

## [Regex Tester](https://www.regextester.com/ "www.regextester.com")

        [abc] 		A single character of: a, b or c
        [^abc] 		Any single character except: a, b, or c
        [a-z] 		Any single character in the range a-z
        [a-zA-Z] 	Any single character in the range a-z or A-Z
        ^ 	Start of line
        $ 	End of line
        \A 	Start of string
        \z 	End of string
        . 	Any single character
        \.      One "." (literal)
        \s 	Any whitespace character
        \S 	Any non-whitespace character
        \d 	Any digit
        \D 	Any non-digit
        \w 	Any word character (letter, number, underscore)
        \W 	Any non-word character
        \b 	Any word boundary
        (...) 	Capture everything enclosed
        (a|b) 	a or b
        a? 	Zero or one of a
        a* 	Zero or more of a
        a+ 	One or more of a
        a{3} 	Exactly 3 of a
        a{3,} 	3 or more of a
        a{3,6} 	Between 3 and 6 of a

&nbsp;

```golang 
patternApp := regexp.MustCompile(`^/?([-\w]*)$`)
patternAPI := regexp.MustCompile(`^/api/?([-\w]*)/?[Z0-9]*/?[z0-9]*$`)
patternAsset := regexp.MustCompile(`^/(scripts/([-\w]+).*\.[js]|styles/([-\w]+).*\.[css]|images/)([-\w]+).*$`)
```

```php
// ^([a-zA-Z0-9]){20}(\.){1}([a-zA-Z0-9]){60}$  <=>  NAME(20).VALUE(60)
preg_match( "/^([a-zA-Z0-9]){20}(\.){1}([a-zA-Z0-9]){60}$/", $input )
```

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

