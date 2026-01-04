// "How I write Go HTTP services after seven years" Mat Ryer 2018
// https://medium.com/statuscode/how-i-write-go-http-services-after-seven-years-37c208122831

package main

type server struct {
	db     *someDatabase
	router *someRouter
	email  EmailSender
}

// HandlerFunc() over Handler()
func (s *server) handleSomething() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        //...
    }
}

// One routes.go file @ "every component"
// Because most code maintenance starts with a URL and an error report, 
// and this shows where to look.
func (s *server) routes() {
    s.router.HandleFunc("/api/", s.handleAPI())
    s.router.HandleFunc("/about", s.handleAbout())
    s.router.HandleFunc("/", s.handleIndex())
    s.router.HandleFunc("/admin", s.adminOnly(s.handleAdminIndex()))
}

// Handlers are methods of `*server`
func (s *server) handleSomething() http.HandlerFunc { ... }

// ... and merely PREP the actual handling 
func (s *server) handleSomething() http.HandlerFunc {
    thing := prepareThing() // called only once 
    return func(w http.ResponseWriter, r *http.Request) {
        // use `thing`        
    }
} // Read-only at shared data, `prepareThing()`, else  mutex required.

// Take arguments for handler-specific dependencies
func (s *server) handleGreeting(format string) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, format, "World")
    }
}

// Can include custom `request` and `response` types too 
func (s *server) handleSomething() http.HandlerFunc {
    type request struct {
        Name string
    }
    type response struct {
        Greeting string `json:"greeting"`
    }
    return func(w http.ResponseWriter, r *http.Request) {
        ...
    }
}

// Middleware :: can conditionally call a handler (h)
func (s *server) adminOnly(h http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        if !currentUser(r).IsAdmin {
            http.NotFound(w, r)
            return
        }
        h(w, r)
    }
}

// Defer (expensive) setup, `sync.Once`, until requested 
func (s *server) handleTemplate(files string...) http.HandlerFunc {
    var (
        init sync.Once
        tpl  *template.Template
        err  error
    )
    return func(w http.ResponseWriter, r *http.Request) {
        init.Do(func(){
            tpl, err = template.ParseFiles(files...)
        })
        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }
        // use tpl
    }
}