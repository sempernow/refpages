# Golang &amp; PostgreSQL | [`sql`](http://go-database-sql.org/modifying.html) |  [`sqlx`](https://jmoiron.github.io/sqlx/) ([Transactions](https://jmoiron.github.io/sqlx/#transactions)) | [&copy;](https://www.alexedwards.net/blog/practical-persistence-sql "Practical Persistence in Go ... 2018 @ AlexEdwards.net") | [&copy;](https://www.alexedwards.net/blog/practical-persistence-sql "... Organising ... 2018 @ AlexEdwards.net") 

## See Labs

- `$GOPATH/f06ygo/db/postgres/...` 
- `$DEV/go/labs/4-sql/...`

## Prepared Statements 

[Use or Avoid?](http://go-database-sql.org/prepared.html)


## Nullable (`db`) Field Values | SQL [Null Types](http://go-database-sql.org/nulls.html) | [&copy;](https://marcesher.com/2014/10/13/go-working-effectively-with-database-nulls/ "... Working with Database NULLs 2016 @ marcesher.com") | [&copy;](https://medium.com/aubergine-solutions/how-i-handled-null-possible-values-from-database-rows-in-golang-521fb0ee267 "2017 @ medium.com")

## TL;DR 

Use pointer field types (`*T`) for any ___nullable___ field. That way the end-to-end interface is `NULL` to/from [JSON `null`](https://stackoverflow.com/questions/21120999/representing-null-in-json "2015 @ StackOverflow.com"), while at Golang (struct) the value is whatever the type's zero value (and `nil` at the pointer itself). Optionally, additionally, use the `json` tag, `json:"foo,omitempty"`, to omit any of zero-value from the JSON result upon `json.Marshal()`.

### Guidelines:

- Avoid db `NULL`able keys.
- Use pointer if db key is `NULL`able.
- Use pointer if JSON key is optional and data layer requires distinction between `null`/(no key) and zero-value cases; or client requires such between [`false`_y_](https://developer.mozilla.org/en-US/docs/Glossary/Falsy "MDN") and `null`/(no key).

## Roundtrip Data-type Flow (`Type` vs `*Type`)

JSON  <==>  Golang  <==>  DB/SQL 

From `json.Decode` to `INSERT`, to `SELECT`, to `json.Marshal`, ___per case___ (no-key vs zero-value).


Database field `Foo *string` type scans to Golang `nil`, and so JSON-marshals to missing key if `json:"foo,omitempty"`, else to `"foo":null`. ___This is the cleanest scheme___; db `NULL` to/from [JSON `null`](https://stackoverflow.com/questions/21120999/representing-null-in-json "2015 @ StackOverflow.com") (or absent key).

### Handling Schemes
_From best to worst:_

1. `Foo *string` type scans (`sql` pkg) and decodes (`json` pkg) to Golang `nil`, and so JSON-marshals to missing key if `json:"foo,omitempty"`, else to `"foo":null`. ___This is the cleanest scheme___; db `NULL` to/from [JSON `null`](https://stackoverflow.com/questions/21120999/representing-null-in-json "2015 @ StackOverflow.com") (or absent key); no need for [Nil UUID](https://tools.ietf.org/html/rfc4122#section-4.1.7 "RFC4122 2005 @ IETF.org") values in its database table (which fail versioned UUID `validator` constraints, e.g., `uuid4`, though validate as `uuid`).

1. `Foo string` type ___fails___ on `SELECT` scan of `NULL` to `string`
    - Use [Nil UUID](https://tools.ietf.org/html/rfc4122#section-4.1.7 "RFC4122 2005 @ IETF.org") (and `NOT NULL` constraint) as a proxy for `NULL`.
    - Handle at (un)marshal. E.g., 
        ```golang 
        // @ Unmarshal
        if got.ID3 == "" {
            got.ID3 = dbUNIL.String
        }
        // @ Marshall
        if s.ID3 == dbUNIL.String {
            s.ID3 = ""
        }

        var (
            // Insert dbUNIL as proxy for NULL (validates as `uuid`, but not `uuid4`)
            // @ Golang: `uuid.Nil`; @ Postgres "uuid-oosp" extension: `uuid_nil()`
            dbUNIL sql.NullString = sql.NullString{String: fmt.Sprintf("%s", uuid.Nil), Valid: true}
        )
        ```
    - This is a workaround, not a genuine solution, since it prohibits (`db`) `NULL`. If no `NULL` fields, then simplify: 
    ```golang 
    dbUNIL := fmt.Sprintf("%s", uuid.Nil)
    ```

1. `Foo sql.NullString` type is itself a struct, and so JSON-marshals as such:
    - `NULL` marshals to `"id3": {"String": "","Valid": false}`
    - Else marshals to `"id3": {"String": "1aad24fd-cf8a-4051-8863-0200f8a26616","Valid": true}`

- `Foo sql.NullString` type ___fails___ on unmarshal of `POST`/`PUT` (from client), unless JSON is of the proper structure (above). I.e.,  `"id3":"1aad24fd-cf8a-4051-8863-0200f8a26616"` fails to unmarshal, so would require similar (un)marshal code as "`Foo string`" case, else client-side (Javascript) modifications.


### SQL [Null Types](http://go-database-sql.org/nulls.html) ::  `sql.NullString` and `sql.NullFloat64`

```golang
type Book struct {
    isbn  string
    title  string
    author string
    price  float32
}
```

> &hellip; we set `NOT NULL` constraints on the columns &hellip; ___If the table contained nullable fields___ we would need to use the `sql.NullString` and `sql.NullFloat64` types instead.

```golang
type Book struct {
    Isbn  string
    Title  sql.NullString
    Author sql.NullString
    Price  sql.NullFloat64
}
```

### Roundtrip Data-type Flow (`Type` vs `*Type`)

From `json.Decode` to `INSERT`, to `SELECT`, to `json.Marshal`, ___per case___ (no-key vs zero-value).

#### `string` (`NOT NULL`able)
- `json:"foo"`

    |JSON|Go|db|JSON|
    |----|--------|---------|---|
    |no `foo`|`""`|`''`|`""`|
    |`null`|`""`|`''`|`""`|
    |`""`|`""`|`''`|`""`|

    - ___No distinction.___

- `json:"foo,omitempty"`

    |JSON|Go|db|JSON|
    |----|--------|---------|---|
    |no `foo`|`""`|`''`|no `foo`|
    |`null`|`""`|`''`|no `foo`|
    |`""`|`""`|`''`|no `foo`|

    - ___No distinction.___

#### `*string` (`NULL`able)

- `json:"foo"`

    |JSON|Go|db|JSON|
    |----|--------|---------|---|
    |no `foo`|`nil`|`NULL`|`null`|
    |`null`|`nil`|`NULL`|`null`|
    |`""`|`""`|`''`|`""`|

    - ___No mutation___ _(Nearly)._

- `json:"foo,omitempty"`

    |JSON|Go|db|JSON|
    |----|--------|---------|---|
    |no `foo`|`nil`|`NULL`|no `foo`
    |`null`|`nil`|`NULL`|no `foo`|
    |`""`|`""`|`''`|`""`|

    - ___No mutation___ _(Nearly)._

#### &hellip; _choose the desired API dynamic (per key)._

## Pairing types across app boundaries

|PostgreSQL|Golang|Javascript|
|----|---|---|
|`BIGINT`|`int`|`integer`|
|`UUID`|`string`|`string`|
|`NUMERIC(5,2)`|???|???|
|`TIMESTAMPTZ`|`time.Time`|`string`|

- @ Golang, ___currency___ may be `float32` or [`currency.Unit{USD}`](https://godoc.org/golang.org/x/text/currency#Unit "godoc.org")


## &nbsp;


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

