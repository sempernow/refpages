// Go Cheat Sheet   https://github.com/a8m/go-lang-cheat-sheet
// GoesToEleven :: Data Structures  https://github.com/GoesToEleven/golang-web-dev/tree/master/001_prereq
package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"text/template"
	"time"
)

// gore : Go REPL : ☩ go install github.com/x-motemen/gore/cmd/gore@latest
/*
	☩ gore
	gore version 0.5.6  :help for help
	gore> :import github.com/sempernow/kit/id
	gore> id.XOR("foo","foobar")
	"\x00\x00\x00"
	gore> id.XOR("foobar","123")
	"W]\\SSA"
	gore> id.XOR("W]\\SSA","123")
	"foobar"
	gore> :q
*/

func Struct2JSON() {
	// Struct <==> JSON
	type UpdateMessage struct {
		Body string
		Form int
	}
	var um = UpdateMessage{
		Body: testkit.StringPointer(updX),
		Form: message.Long,
	}
	body, err := json.Marshal(&um)
	if err != nil {
		t.Fatal(err)
	}
	// ... @ request ...
	bytes.NewBuffer(body)
}

func foo(){
	updX := "Want update FORBIDDEN."
	body := `{"body": "` + updX + `","form":2}`
	//... @ request ...
	strings.NewReader(body)
}
// Run bash command(s)
cmd := exec.Command("docker", "run", "-P", "-d", "postgres:11.1-alpine")
cmd.Run()

// Shuffle a slice 
rand.Shuffle(len(x), func(i, j int) { x[i], x[j] = x[j], x[i] })

// Sort slice by key  https://golang.org/pkg/sort/#pkg-overview
sort.Slice(mm, func(i, j int) bool {
	return mm[i].Date.Before(mm[j].Date)
}) //... to ascending order

// Sort slice by key  https://golang.org/pkg/sort/#pkg-overview
sort.Slice(people, func(i, j int) bool {
	return people[i].Age < people[j].Age
})// ... to ascending order

// `doTo(..)` mutates a slice, and we want such changes to PERSIST after the call.
// *********************************************************************************
// PASS the slice BY VALUE, `[]aStruct`, IF MUTATING ONLY the VALUES OF the ELEMENTS; 
// neither their number nor position. Else, PASS BY POINTER, `*[]aStruct`.
// That is, if you want the mutations performed on the slice to survive the call.
// https://medium.com/swlh/golang-tips-why-pointers-to-slices-are-useful-and-how-ignoring-them-can-lead-to-tricky-bugs-cac90f72e77b
// *********************************************************************************
func doTo(aa []aStruct) {/*... mutate the slice ...*/}

// Variadic PARAMS/ARGS per CSV (compiled as slice)
func foo(x ...string) {// TAKE csv/slice (params)
	bar(x...) // GIVE csv/slice (args)
}
foo("a","b","c") // USE

// Code block  
x := "otherwise unused"
do := func(b bool) {
	if !b {
		return
	}
	// ***  DEV/DEBUG  ***
	//... do stuff on `x`, per `b` param ... 
	//... compiles doesn't complain of "x declared but not used"
	// ***  END DEV/DEBUG  ***
}
do(true) // run per true|false

// ----------------------------------------------------------------------------
// Type Assertion :: to ACCESS underlying (CONCRETE) TYPE
// of an INTERFACE type variable (`ifc`).

// @ ifc (underlying type) is one of several possible types ...
var (
	j   []byte
	err error
)
switch x := ifc.(type) {
case string:
	j = []byte(x) // Is already encoded.
default:
	j, err = json.Marshal(x)
	if err != nil {
		return err
	}
}
// ... j survives (as type []byte).

// @ ifc (underlying type) should be of one specific type  ...
var m Meta 
if x, ok := ifc.(Meta); ok == true {
	m = Meta{
		NS:    x.NS,
		Build: x.Build,
		Assets: Assets{
			PathRoot: x.PathRoot,
			PathSrc:  x.PathSrc,
			PathDst:  x.PathDst,
		},
	}
}
//... m survives (as type Meta).

// Converting SLICEs of INTERFACE 
// https://stackoverflow.com/questions/12753805/type-converting-slices-of-interfaces#12754757


// ----------------------------------------------------------------------------
// Memoizer 
func foo() func(int) int {
    i := 0
    return func(j int) int {
        i += j
        return i
    }
}
func doFoo() {
    bar := foo()
    fmt.Println(bar(10)) // Prints 10
    fmt.Println(bar(10)) // Prints 20
}

// ----------------------------------------------------------------------------
// GOROUTINEs :: DESIGN PATTERNs

	// How to wait for (unknown number of) goroutines to end.
	// SOLN: WaitGroup
	// Type: `sync.WaitGroup`, funcs: `wg.Add(1)` and `wg.Done()`

	var wg sync.WaitGroup // Type 
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func(i int) {
			fmt.Printf("%d ", i)
			wg.Done()
		}(i)
	}

// Read/Write to a MAP (concurrently)
// `sync.RWMutex`, 
// SOLN:  PASS by POINTER

	// Ex. 1  https://eli.thegreenplace.net/2018/beware-of-copying-mutexes-in-go/
	type Container struct {
	  counters map[string]int
	  sync.Mutex                      
	}
	func (c *Container) inc(name string) {
	  c.Lock()
	  defer c.Unlock()
	  c.counters[name]++
	}

	// Ex. 2 :: WaitGroup + Mutex
	type App struct {
		mu sync.RWMutex
		WG    sync.WaitGroup
		//...
		Cache AppCache
	}
	type AppCache struct {
		html map[string][]byte
		tpls map[string][]byte
	}
	func Builds(app *App) func(v View) {
		return func (v View) {
			defer app.WG.Done()
			app.Cache.Lock()
			defer app.Cache.Unlock()
			//...
		}
	}


// ----------------------------------------------------------------------------
/* 
	Project structure:: Organize as a Library
	- Separate logic (library) from "binary" (main.go)
	- Allows for multiple executables, per context, e.g.,  
		web and commandline uses; share the same library.

		adder/
		  adder.go
		  cmd/
		    adder/
		      main.go
		    adder-server/
		      main.go

	// To install ALL the binaries in ONE command:
	$ go get PKGPATH/...

	https://medium.com/@benbjohnson/structuring-applications-in-go-3b04be4ff091  
*/

// ----------------------------------------------------------------------------
// SLICEs :: Passing as param to function or method 
// IF result will mutate Slice Header, then pass as pointer OR return the slice.
s := foo(s) 
// or
func (s *T) foo() {...}
// https://blog.golang.org/slices
{
	type path []byte

	func (p *path) Parent() {
		i := bytes.LastIndex(*p, []byte("/"))
		if i >= 0 {
			*p = (*p)[0:i]
		}
	}
	func doParent() {
	    x := path("/usr/bin/tso")  
	    x.Parent()
	    fmt.Printf("%s\n", x)    // "/usr/bin"  
	}
}


// ----------------------------------------------------------------------------
// Servers 

// http.handler PATTERN  https://golang.org/pkg/net/http/#Handler

	// http.Handle()
		type aHandler struct {
		    // ...
		}
		func (h aHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
		    w.Write([]byte(`Server response.`))
		}

	// http.HandlerFunc()
		func aHandlerFunc(w http.ResponseWriter, r *http.Request) {
		    w.Write([]byte(`hello world`))
		}

	func main() {
	    http.Handle("/path.do.aHandler", aHandler{})
	    http.Handle("/path.do.aHandlerFunc", http.HandlerFunc(aHandlerFunc))
		http.HandleFunc("/path.do.aHandlerFunc", aHandlerFunc) // EQUIVALENT to above line.
	    http.ListenAndServe(":8080", nil)
	}

	// Middleware SIGNATURE :: accepts AND returns `http.Handler`
		func(h http.Handler) http.Handler

		func (s *Server) midHandlerFunc(w http.ResponseWriter, r *http.Request) {
		      w.Write([]byte("Middleware."))
		}

// ----------------------------------------------------------------------------
// HTTP Cookie 

// Use @ `Expires: future,`
var h, m, s time.Duration = 1 // 1 hr 1 min 1 sec
future = time.Now().Add(time.Hour*h + time.Minute*m + time.Second*s)

func setCookie(w http.ResponseWriter, req *http.Request) {
	c := &http.Cookie{
		Name:  "cookie-name",
		Value: "cookie-value",
		Secure: true,
		HttpOnly: true,  // no JS access; use @ persistent 
		SameSite: SameSite, // a Golang security scheme
		Domain: "so.client.sends.to.this.domain.ONLY.com", // sans defaults to Host-only 
		Path: "/trusted/path",
		Expires: "Mon, 1st Jan 2018 00:00:00 GMT", // *time.Time  - Use only If NOT Session Cookie
		// <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
		Max-Age: -1, // If Session Cookie; same as if omit both `Expires` and `Max-Age`
	}
	http.SetCookie(w, c)
	fmt.Println(c)
	fmt.Fprintln(w, "YOUR COOKIE:", c)
}

// ----------------------------------------------------------------------------
// POINTERs :: A function that returns a pointer 
{
	// call the function 
	n := rtnPtr() 

	// reference its value 
	fmt.Println("Value of n is: ", *n) 
}
// Return a pointer type 
func rtnPtr() *int { 
	x:= 100 
	return &x 
} 

// ACCESS slice POINTER @ for loop
	(*s)[i]  

const tplPath = "template.gohtml"

var tpl *template.Template

func main() {
	MAPs()
	FILEs()
}
func MAPs() {
	m := make(map[string]int)
	m["key-1"] = 42
	m["key two"] = 12
	fmt.Println(m)
	for k, v := range m {
		fmt.Println(k, v)
	}
}

const (
	tplPath       = "index.gohtml"
	assetFilePath = tplPath + ".go"
)

// ----------------------------------------------------------------------------
// FILEs :: io/ioutil
func strToFile() {
	// EMBED asset
	b, err := ioutil.ReadFile(tplPath)
	chk(err)
	s := "package main\n\nfunc asset() []byte {" +
		"\n\treturn " + fmt.Sprintf("%#v", b) + "\n}"
	w, err := os.Create(assetFilePath)
	chk(err)
	_, err = io.WriteString(w, s)
	chk(err)
}

func readWriteFile() {
	in, err := os.Open(os.Args[1])
	chk(err)
	defer in.Close()
	out, err := os.Create("out.txt")
	chk(err)
	bs, err := ioutil.ReadAll(in)
	chk(err)
	_, err = out.Write(bs)
	chk(err)
}

func fileExists(f string) bool {
	i, err := os.Stat(f)
	if os.IsNotExist(err) {
		return false
	}
	return !i.IsDir()
}

// ----------------------------------------------------------------------------
// TEMPLATEs  https://golang.org/pkg/text/template/ 

func init() {
	// Read/parse templates per GLOB @ `dirAppShell`
	tplsPath = filepath.Join(dirAppShell, "templates", "*")
	tpls = template.Must(template.ParseGlob(tplsPath))

	// Read/parse templates @ `tplPath`
	tplPath = filepath.Join(dirAppShell, "templates", "foo.gohtml")
	tpl = template.Must(template.ParseFiles(tplPath))

	// Read template into `data` []byte
	data, err := ioutil.ReadFile(tplPath)
	chk(err)
	// Parse `data` as string
	tpl, err = template.New(tplPath).Parse(string(data))
	chk(err)
}

// EXECUTE a parsed TEMPLATE (tpl *Template)

	// @ `tpl` is ONE parsed template file.
	func (tpl *Template) Execute(w io.Writer, data interface{}) error
	tpl.Execute(out,data)

	// @ `tpl` is SEVERAL parsed template FILES.
	func (tpl *Template) ExecuteTemplate(w io.Writer, tplName string, data interface{}) error
	tpl.ExecuteTemplate(out, tplName, data)

// Template => Map 
func tplToMap() func(chn *Channel) string {
	built := make(map[string]string)
	return func(chn *Channel) string {
		if built[chn.ChnID] != "" {
			return built[chn.ChnID]
		}
		fmt.Println("Build ONCE!")
		//b := &bytes.Buffer{}  // less efficient than Builder
		b := &strings.Builder{} // https://golang.org/pkg/strings/#Builder
		tpls.ExecuteTemplate(b, chn.Name+".gohtml", getAllMessages(chn))

		built[chn.ChnID] = b.String()
		return built[chn.ChnID]
	}
}

// Template => FILE 
func tplToFileOrStdout() {
	// Template @ STRING
	tpl, err := template.New(tplFname).Parse(tplString)
	// Template @ FILE 
	tpl,err  := template.Must(template.ParseFiles(tplPath1, tplPath2))
	chk(err)

	w, err := os.Create(tplPath)                         // IF NOT EXIST 
	w, err := os.OpenFile(tplPath, syscall.O_RDWR, 0755) // IF EXIST
	chk(err)
	defer func() {
		err = w.Close()
		chk(err)
		mtimePerSource(mdPathSans)
	}()

	tplData := struct{ Title, Main string }{Title: "Test", Main: "Good!"}
	// to FILE 
	err = tpl.ExecuteTemplate(w, tplName, &tplData)
	err = tpl.Execute(f, &tplData) // ... if `tpl` is only ONE parsed template.
	// to STDOUT
	err = tpl.Execute(os.Stdout, &tplData)
	chk(err)
}

// ----------------------------------------------------------------------------
func validateArg(a []string) string {
	instruct := getSelfName() + " REQUIREs a valid Markdown-file path (1 ARG)."
	if len(a) < 2 {
		log.Fatal(instruct)
	}
	if !fileExists(a[1]) {
		log.Fatal(instruct)
	}
	return a[1]
}

// ----------------------------------------------------------------------------
// SELF :: BRITTLE; FAILs @ go run ... 
func getSelfName() string {
	self, _ := exec.Command("sh", "-c", "go list -f '{{ .Target }}'").Output()
	self = self[:len(self)-1]
	return filepath.Base(string(self))
}

func getSelfPath() string  {
	return binPath, _ := filepath.Abs(filepath.Dir(os.Args[0]))
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

// ----------------------------------------------------------------------------
// SET MTIME per REF FILE :: Set target file mtime to that of reference file.
func mtimePerRef(target, ref string) {
	r, e := os.Stat(ref)
	chk(e)
	mdtime := r.ModTime()
	e = os.Chtimes(target, time.Now().Local(), mdtime)
	chk(e)
}

func chk(e error) {
	if e != nil {
		log.Fatal(e)
	}
}
