# Go &amp; JSON 

## `json.Marshal` &mdash; Go _to_ JSON

```golang 
type model struct {
    State    bool
    Pictures []string
    FooBar   string `db:"foo_bar" json:"fooBar,omitempty"`
    FooBar2  string `db:"foo_bar_2" json:"fooBar2"`
    // The JSON "omitempty" affects only Marshalling (struct to JSON); 
    // does NOT AFFECT struct on Unmarshal (JSON to struct)
}

m := model{
    State: true,
    Pictures: []string{
        "one.jpg",
        "two.jpg",
        "three.jpg",
    },
    FooBar: "", 
}

b, err := json.Marshal(m)
if err != nil {
    fmt.Println("FAIL @ json.Marshal: ", err)
}

os.Stdout.Write(b)
```

```bash
☩ go run .
{"State":true,"Pictures":["one.jpg","two.jpg","three.jpg"],"fooBar2":""}}
```
- Note that `omitempty` ensures JSON key is ___omitted___, 
whether or not its struct field (key) is present, 
as long as the value thereof is it's type's ___zero-value___.


## `json.Unmarshal` &mdash; JSON _to_ Go

```golang 
var data img
rcvd := `{
        "Width": 800,
        "Height":600,
        "Title":"Foo Bar",
        "Thumbnail":{
            "Url":"http://www.example.com/image/481989943",
            "Height":125,
            "Width":100
        },
        "Animated":false,
        "IDs":[116,943,234,38793]
    }`

type thumbnail struct {
    URL           string
    Height, Width int
}

type img struct {
    Width, Height int
    Title         string
    Thumbnail     thumbnail
    Animated      bool
    IDs           []int
}

err := json.Unmarshal([]byte(rcvd), &data)
if err != nil {
    log.Fatalln("FAIL @ json.Unmarshal", err)
}

fmt.Printf("%+v\n", data)
```

```bash
☩ go run .
{Width:800 Height:600 Title:Foo Bar Thumbnail:{URL:http://www.example.com/image/481989943 Height:125 Width:100} Animated:false IDs:[116 943 234 38793]}
```

### JSON `null` ___maps to___ the Golang ___type's zero value___; `""`, `0`, `{}`, `[]`

```golang 
rcvd = `null`
```
```bash
☩ go run .
{Width:0 Height:0 Title: Thumbnail:{URL: Height:0 Width:0} Animated:false IDs:[]}
```
|JSON|Golang (`struct`)|
|-----------------|---------------------|
|`{"Thumbnail":{}}`| `{Thumbnail:{URL: Height:0 Width:0}}`|
|`{"Thumbnail":null}`| `{Thumbnail:{URL: Height:0 Width:0}}`|
|`{"IDs":null}`| `{IDs:[]}`|
|`{"Width":null}`| `{Width:0}`|
|`{"Title":null}`| `{Title:}`|

### JSON keys ___ommitted___ map same as `null` 

```golang 
rcvd = `{
    "Width": 800,
    "Title":"Foo Bar"
}`
```
```bash
☩ go run .
{Width:800 Height:0 Title:Foo Bar Thumbnail:{URL: Height:0 Width:0} Animated:false IDs:[]}
```

#### Note `null` is a javascript keyword.

## JSON Tags

Allow for namespace maps, per domain (per package); `json.`, `db.`, .... Note that __conditionals__, e.g., `omitempty`, apply on mapping ___from struct___ to &hellip; JSON, DBMS query, or whatever, ___only___; they ___do not apply to___ __`json.Unmarshal`ling__. 

```golang
type img struct {
    Width, Height int
    Title         string
    Thumbnail     thumbnail
    Animated      bool
    IDs           []int
    FooBar        string `db:"foo_bar" json:"fooBar,omitempty"` 
    //... JSON key is omitted on Marshalling (struct to JSON). 
    //... Does NOT AFFECT struct on Unmarshal (JSON to struct)!
}
```
```golang 
rcvd = `{
    "Width":800
}`
```
```bash
☩ go run .
{Width:800 Height:0 Title: Thumbnail:{URL: Height:0 Width:0} Animated:false IDs:[] FooBar:}
```

## Pointer Types @ Unmarshal (JSON to Go)

With one simple test for `nil`, pointer field types allow us to set and abide ___validation___ criteria, including those against type's zero-value,
yet conditionally ___bypass validation___ _on absesnt key and key having_ `null` _(javascript keyword) value_.

This trick works for all Golang value types (those pointed to); `int`, `string`, `[]byte`, `struct{}`, &hellip; their zero-values are _not_ `nil`.

```golang
// User ...
type User struct {
    Uname *string //`json:"uname,omitempty"`
}

func main() {
    var u1, u2, u3 User
    json.Unmarshal([]byte(`{"uname":""}`), &u1)   // the type's zero-value
    json.Unmarshal([]byte(`{}`), &u2)             // absent key
    json.Unmarshal([]byte(`{"uname":null}`), &u3) // null (javascript keyword)

    fmt.Println("uname set:", u1.Uname != nil, *u1.Uname)
    fmt.Println("uname set:", u2.Uname != nil, u2.Uname) // Can't dereference nil pointer
    fmt.Println("uname set:", u3.Uname != nil, u3.Uname) // Can't dereference nil pointer
}
```
```bash
☩ go run .
uname set: true 
uname set: false <nil>
uname set: false <nil>
```

### [`json-validation/pattern-3.go`](json-validation/pattern-3.go)
```golang
// UserP3 is case/pattern handles cases where want keys to bypass validation if not sent or null.
type UserP3 struct {
	Name     *string `json:"name" validate:"required,min=1"` 
	Age      *uint   `json:"age"  validate:"omitempty,gte=1"`
	Addr     *string `json:"addr" validate:"min=1"`
	FavColor string  `json:"favColor"`
} // Use this struct only @ Unmarshal (JSON to Go)

// Pointers with `"omitempty"` bypass validation (validate) on null||not-sent,
// yet are caught (invalidate) if condition not met when sent and not null.
```

### `.Decode`, vs. `.Unmarshal` 

```golang
if err := json.NewDecoder(jStream).Decode(&toThisStruct); err != nil {
    fmt.Printf("FAIL @ Unmarshalling (JSON to struct) \n%s\n", err)
}
```

- Use `json.Decoder` if the JSON data is coming from an `io.Reader` stream, such as an HTTP request.
- Use `json.Unmarshal` if the JSON data is already in memory, as `[]byte`.


## Pairing types across app boundaries

|PostgreSQL|Golang|Javascript|
|----|---|---|
|`BIGINT`|`int`|`integer`|
|`UUID`|`string`|`string`|
|`NUMERIC(5,2)`|???|???|
|`TIMESTAMPTZ`|`time.Time`|`string`|

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

