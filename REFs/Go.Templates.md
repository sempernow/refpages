# [Templates](https://golang.org/pkg/text/template/ "text/template pkg @ golang.org") 

Data-driven templates for generating textual output. 

```golang
type Stuff struct {
	Material string
	Count    uint
}
foo := Stuff{"wool", 17}
tmpl, _ := template.New("test").Parse("These {{.Count}} items are {{.Material}}")
tmpl.Execute(os.Stdout, foo)
```

`Stdout`: "These 17 items are wool"

- Templates are first _parsed_, and then _applied_ to a data structure. 
- Template _annotations_ refer to elements of the data structure, e.g., a `struct` field, or a `map` key). 
- _Execution_ ___walks the structure___ and sets the ___cursor___, called "dot" ("`.`"), which is the value at the current location. So, "`.Method`" result is the value of invoking the method with dot as the
  receiver, e.g., `dot.Method()`.
- [Actions](https://golang.org/pkg/text/template/#hdr-Actions) &mdash; data evaluations or control structure; delimited by "`{{`" and "`}}`"; 
    - [Arguments](https://golang.org/pkg/text/template/#hdr-Arguments) &mdash; a simple value denoted by: a Golang variable value, `nil`, `.`, `$aVarName`, `.Field`, `.Field1.Field2`, `.Key`, `.Method`
        - [Text and spaces](https://golang.org/pkg/text/template/#hdr-Text_and_spaces)
            - "`{{23 -}} < {{- 45}}`" renders "`23<45`"
    - [Pipelines](https://golang.org/pkg/text/template/#hdr-Pipelines); `Argument`, `.Method [Argument...]`, `functionName [Argument...]`
- [Variables](https://golang.org/pkg/text/template/#hdr-Variables)

## Nested Templates 

```
{{ template "header" .App }}

{{ template "main" . }}

{{ template "footer" }}
```

- The `header` template takes the `App` struct (`.App`), and the `main` template takes all (`.`), which may be a nested (composite) struct. A Golang ___design pattern___ is to create such an anonymous struct comprised of all the structs required by the template. 

## Data @ Multiple Structs 

Compose the requiste `data` struct, which can be anonymous, by ___nesting whatever structs are necessary___ to fulfill template requirements, declaring which elements are _applied_ where, using the template-dot notation, e.g., `{{.Page.Name}}`. 

```html
<h1>{{.Page.Name}}</h1>
<h2>Wisdom</h2>
<ul>
    {{if .Wisdom}}
        {{range .Wisdom}}
        <li>{{.Name}} - {{.Motto}}</li>
        {{end}}
    {{end}}

</ul>
<h2>Transport</h2>
<ul>
    {{range .Transport}}
    <li>{{.Name}} - {{.Model}} - {{.Doors}}</li>
    {{end}}
</ul>
```

```golang
data := struct {
    Page      pg
    Wisdom    *[]sage
    Transport []car
}{
    page,
    &sages,
    cars,
}

b := &strings.Builder{}
tpls.ExecuteTemplate(b, page.fname+".gohtml", data)
```

- Note a struct field that is a struct type may be named (aliased) or not. 

## Most Common Functions 

### Parse Template(s)

#### Read/parse template file(s) per GLOB @ `dir`

```golang
paths = filepath.Join(dir, "templates", "*")
tpls = template.Must(template.ParseGlob(paths))
```

#### Read/parse a template (@ `path`)

```golang
path = filepath.Join(dir, "templates", "foo.tpl")
tpl = template.Must(template.ParseFiles(path))
```

#### Read a template file into a slice (`[]byte`)

```golang 
data, err := ioutil.ReadFile(tplPath)
chk(err)
```

#### Parse a string 

```golang
tpl, err = template.New(tplPath).Parse(string(data))
chk(err)
```

### Execute Parsed Template(s) (`tpl *Template`)

#### @ `tpl` is ___one___ parsed template file 

```golang
tpl.Execute(out,data)
```

##### `Execute()` signature

```golang
func (tpl *Template) Execute(w io.Writer, data interface{}) error
```

#### @ `tpl` is ___several___ parsed template files.

```golang
tpl.ExecuteTemplate(out, tplName, data)
```

##### `ExecuteTemplate()` signature

```golang
func (tpl *Template) ExecuteTemplate(w io.Writer, tplName string, data interface{}) error
```

==== Goes To Eleven ====

# Passing Data To Templates

You get to pass in one value - that's it!

Fortunately, we have many different types which that value can be including composite types which compose together values. (These are also known as aggregate data types - they aggregate together many different values).

## Slice
Use this for passing in a bunch of values of the same type. We could have a []int or a []string or a slice of any type.

## Map 
Use this for passing in key-value data.

## Struct
This is probably the most commonly used data type when passing data to templates. A struct allows you to compose together values of different types.

# Template variables

## [template variables](https://godoc.org/text/template#hdr-Variables)

### ASSIGN
``` Go
{{$wisdom := .}}
```

### USE
``` Go
{{$wisdom}}
```

A pipeline inside an action may initialize a variable to capture the result. The initialization has syntax
 
 $variable := pipeline
 
 where $variable is the name of the variable. An action that declares a variable produces no output.
 
 If a "range" action initializes a variable, the variable is set to the successive elements of the iteration. Also, a "range" may declare two variables, separated by a comma:
 
  range $index, $element := pipeline
  
 in which case $index and $element are set to the successive values of the array/slice index or map key and element, respectively. Note that if there is only one variable, it is assigned the element; this is opposite to the convention in Go range clauses.
 
 A variable's scope extends to the "end" action of the control structure ("if", "with", or "range") in which it is declared, or to the end of the template if there is no such control structure. A template invocation does not inherit variables from the point of its invocation.
 
 When execution begins, $ is set to the data argument passed to Execute, that is, to the starting value of dot.

# Using functions in templates

## [template function documentation](https://godoc.org/text/template#hdr-Functions)

***

## [template.FuncMap](type FuncMap map[string]interface{})

FuncMap is the type of the map defining the mapping from names to functions. Each function must have either a single return value, or two return values of which the second has type error. In that case, if the second (error) return value evaluates to non-nil during execution, execution terminates and Execute returns that error.

## [template.Funcs](https://godoc.org/text/template#Template.Funcs)
``` Go
func (t *Template) Funcs(funcMap FuncMap) *Template
```

***

During execution functions are found in two function maps: 
- first in the template, 
- then in the global function map. 

By default, no functions are defined in the template but the Funcs method can be used to add them.

Predefined global functions are defined in text/template.

# Global Functions

There are "predefined global functions" which you can use.

[You can read about these functions here](https://godoc.org/text/template#hdr-Functions)

The following code samples will demonstrate some of these "predefined global functions":

- index

- and

- comparison
 
# Nested templates

[nested templates documentation](https://godoc.org/text/template#hdr-Nested_template_definitions)

## define: 
``` Go
{{define "TemplateName"}}
insert content here
{{end}}
```
## use: 
``` Go
{{template "TemplateName"}}
```

# Passing data to templates 

## `011_composition-and-methods`

These files provide you with more examples of passing data to templates.

These files use the [composition](https://en.wikipedia.org/wiki/Composition_over_inheritance) design pattern. You should favor this design pattern. 

Read more about [composition with Go here](https://www.goinggo.net/2015/09/composition-with-go.html).

# Hands-on exercises

These hands-on exercises will help you learn how to pass data to templates.

I have found that many students need practice with passing data to templates.

## Take-away

One of the main take-aways is to use a composite data type. Often this data type will be a struct. Build a struct to hold the different pieces of data you'd like to pass to your template, then pass that to your template.