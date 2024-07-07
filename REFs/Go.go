/*
	Golang paradigm is to SHARE MEMORY BY COMMUNICATING, 
	NOT to communicate by sharing memory.

	Golang is CSP-based :: Communicating Sequential Processes 
	Concurrrence per independent processes executing sequentially,
	and communicating by message-passing; thus STACK TRACEable;
	http://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/ 

	Paradigm:             compiled, concurrent, imperative, structured 
	Typing discipline:    strong, static, inferred, structural 
	Implementation lang:  Golang, assembly language, previously C (gc); C++ (gccgo) 
	License:              BSD-style + patent grant 
	https://en.wikipedia.org/wiki/Go_(programming_language) 

	Golang implements the goodness of OOP without classes; is NOT an OOP language. 

		(1) Encapsulation               (2) Reusability 
		    state (fields)                  inheritence (embedded types) 
		    behavior (methods) 
		    exported/un-exported  

		(3) Polymorphism                (4) Overriding 
		    interfaces                      promotion

		Golang enables substitutability through subtype polymorphism (3). 
		Encapsulation (1) is at the package level, by namespace.  
		All through orthogonal interfaces (2,3,4) and methods on structs (1,2,4); 
		both of which allow embedding (2), and thereby overriding (4). 

	Golang Memory Model  https://golang.org/ref/mem  
	"
		The Golang memory model specifies the conditions under which reads of a variable in one goroutine can be guaranteed to observe values produced by writes to the same variable in a different goroutine. 
		
		Advice: Programs that modify data being simultaneously accessed by multiple goroutines must serialize such access. To serialize access, protect the data with channel operations or other synchronization primitives such as those in the sync and sync/atomic packages. If you must read the rest of this document to understand the behavior of your program, you are being too clever. Don't be clever.  
	"
	Golang supports TWO STYLES of CONCURRENT PROGRAMMING:
		- SHARED MEMORY MULTITHREADING, per MUTEXES, CONDITIONAL VARIABLES, 
		  ATOMIC COUNTERs, and such, available in many other languages.
		- CSP, per GOROUTINES and CHANNELS, unique to Golang.

	Overview
		Go by Example  https://gobyexample.com/ 
		GoesToEleven   https://github.com/GoesToEleven/golang-web-dev/tree/master/001_prereq 
		Cheat Sheet    https://github.com/a8m/go-lang-cheat-sheet 

	Install        https://golang.org/dl/           Start
	Commands Doc   https://golang.org/doc/cmd/      Build Tools
	GoDoc.org      https://godoc.org/               Package Search
	Packages Doc   https://golang.org/pkg/          Standard Library  
	Language Spec  https://golang.org/ref/spec      Spec

	How to Go      https://golang.org/doc/code.html                       Ecosystem Ref 
	Effective Go   https://golang.org/doc/effective_go.html               Best Practices Ref 
	GoPL book      https://notes.shichao.io/gopl/                         The Book (notes) 
	GoPL code      https://github.com/adonovan/gopl.io                    The Book (code repo) 
	Go CodeReview  https://github.com/golang/go/wiki/CodiewComment: Knowledge Base 
	Go Wiki        https://github.com/golang/go/wiki                      Resources List 

	Go by Example  https://gobyexample.com/                               Practical Tutorial 
	TDD            https://quii.gitbook.io/learn-go-with-tests/           TDD-based Tutorial (WIP) 
	A Tour of Go   https://tour.golang.org/welcome/3                      Intro Tutorial 
	GoesToEleven   https://github.com/GoesToEleven/GolangTraining         Training/Labs (code repo) 

	PERFORMANCE Limits
		1. Latency @ Network + Disk I/O
		2. (Heap) Allocations + Garbage Collector (GC)

		Note that all "allocations" refer to that of Heap (or Data segment), NOT of the stack.
		Stack is self-cleaning.

		GC 2018 https://blog.golang.org/ismmkeynote
*/

// INSTALL  https://golang.org/doc/install  |  https://golang.org/dl/   
	// @ Linux
		$ ver=1.22.5
		$ arch=amd64
		$ curl -sSL https://go.dev/dl/go${ver}.linux-${arch}.tar.gz |sudo tar -C /usr/local/go$ver -xz
		// @ ~/.bashrc
		// # Configure to newest Golang version if any installed @ /usr/local/go[N.N.N]
		// export GOROOT=$(find /usr/local -maxdepth 1 -type d -path '*/go*' |sort |tail -n 1) \
		//     && export PATH=$GOROOT/bin:$PATH
		$ sudo yum install git      // RHEL|CentOS|Fedora 
		$ sudo apt git              // Ubuntu|Debian 
		                            // https://git-scm.com/download/linux 
		// @ Windows 
		choco install golang 
		choco install git           // Windows  

		//... MUST INSTALL a VCS/SVC tool {git, hg, svn}
		//    REQUIREd by `go get` tool; 

	// ALSO add $GOBIN (path) to PATH environment variable 

	// ISSUE @ WSL: Owner/Perms ISSUE: `go get ...`; ERR: "... denied ..."
		// Must make go dir available to all users, 
		// which is NOT the default install state.
	// FIX @ WSL: Change owner (user:group) to regular user (recurse):
		// ☩ sudo chown -R $USER:$USER /usr/local/go 
		// ☩ # VERIFY ...
		// ☩ ls /usr/local
		// drwxr-xr-x 1 root root 4096 Jun 18 17:28 bin
		// drwxr-xr-x 1 root root 4096 Mar  4 10:52 etc
		// drwxr-xr-x 1 uzr7 uzr7 4096 Jun  1 15:43 go
		//...
	// REFERENCE: Permissions for executables
		// ☩ sudo chmod 755 <FILE>  

// ENVIRONMENT VARIABLES  https://golang.org/cmd/go/#hdr-Environment_variables 
	GOROOT  // Golang install directory, e.g., /usr/local/go1.22.2 
	GOBIN   // Path to go tools and other binaries of Golang proper; $GOROOT/bin
	GOPATH  // Workspaces (projects) default; ignored by modules (Projects of `go mod init`)
	// Golang sets DEFAULTs if unset, so needn't set any of these environment vars; 
	// HOWEVER, the GOBIN path must be in PATH. (Default GOBIN is '/usr/local/go/bin'.)
	export PATH=$PATH:$GOBIN  // May add additional binaries path(s), e.g., those of project(s); 
	// I.e., the OS itself must be able to find the binary, whether of a go tool or a project.

	// @ Linux/MinGW/Cygwin      	@ Windows/Cygwin 
	// ====================      	=================
	GOROOT=/usr/local/go         	GOROOT=%SystemDrive%\go
	GOPATH="/c/Users/${USER^^}/go" 	GOPATH=%USERPROFILE%\go
	GOBIN=$GOROOT/bin            	GOBIN=%GOROOT%\bin       // @ install Golang TOOLS (default)
	GOBIN=$GOPATH/bin            	GOBIN=%GOPATH%\bin       // @ install project binaries

	go env            // Print all Golang Environment variables 
	go env GOPATH     // Print GOPATH Env. var. 
	go help gopath    // Print info regarding the topic "gopath"  

	// May (re)set GOPATH & GOBIN per project, or ad hoc;
	// HOWEVER, the PATH environment variable must include the GOBIN (go tools) path. 
		export GOPATH=$HOME/gobook        // set workspace SOURCE directory; packages    (*.go)
		export GOBIN=$GOPATH/bin          // set workspace BINARY directory; executables (*.exe)
		go get -u gopl.io/ch1/helloworld  // fetch, build, install (binary to GOBIN)
		$GOPATH/bin/helloworld            // run
		Hello, 世界
		// If GOBIN is in PATH 
		export PATH=$PATH:$GOBIN
		// Then ...
		helloworld                       // run @ linux|Win
		./helloworld                     // run @ MinGW64|Cygwin
		Hello, 世界

	// NOTE @ change to root user, the envirnment may lack GOBIN in PATH. 
		// Solution:
		sudo -E su  // Preserve current env. while root user; cursor remains unchanged.
		whoami      // Note `-E` @ root user is dangerous because cursor remains unchanged.

	go install ...  // MAY REQUIRE root privileges (if GOBIN @ standard location).

// goimports :: AUTO FIX package `import ...` PATHS 
	go get golang.org/x/tools/cmd/goimports // Download and install it

	goimports -w . // Overwrite all files thereunder 
	goimports -h   // Help

// GO TOOLs  https://rakyll.org/go-tool-flags/ 
	// REQUIREs Golang env vars AND all its rigid directory structures.
	// When NOT under GOPATH/src, some Golang tools will sort of work; 
	// Use simple commands @ project folder; `go run .` or `go build .`, ...
		go COMMAND [ARGUMENTS]  // manages Golang code  https://golang.org/cmd/go/
		go help COMMAND // List all options
			// BUILD  https://golang.org/pkg/go/build/  
			build       // COMPILE packages and dependencies (.exe @ PWD)
				-o NAME                      // Name of binary file; default is folder-name 
				// @ Compiler flags  @ https://golang.org/cmd/compile/
				-gcflags [PATTERN=]arg list  // arg list to pass per compile invocation
				// @ Linker flags    @ https://golang.org/cmd/link/
				-ldflags // CHANGE var value(s) at build time
					go build -ldflags="-X '<PATH>/<pkg>.<varname>=<valnew>'"
					// https://www.digitalocean.com/community/tutorials/using-ldflags-to-set-version-information-for-go-applications
					// ... embed version details, licensing info, ... per command line. 
					go build -v -ldflags="-X 'main.Version=v1.0.0' \
						-X 'app/build.User=$(id -u -n)' \
						-X 'app/build.Time=$(date)'"
				// Historical: CFLAGS and LDFLAGS are predifined rules @ GNU `make`; 'C' for C-compiler name; 'LD' for C-linker name.

			// Build per OS / Arhitecture
				go dist list       // show All supported GOOS/GOARCH combinations
				go env GOOS GOARCH // show Current 

				// Build tag : Build for everything except Windows ...
					// +build !windows

				// Build for android/arm64
				GOOS=android GOARCH=arm64 go build

				//... per fname 
				foo_${GOOS}_${GOARCH}.go
				foo_android_arm64.go 

			clean       // remove object files
			doc NAME [FUNCTION]  // run `godoc` on NAME [FUNC]; 
				pkgPath/pkgName [funcName]  // path RELATIVE to `$GOPATH/src`
				// info per pkgName.go comments; function signatures and desc,etc
				// e.g., show doc for json.Number's Int64 method.
				json.Number.Int64  // or `go doc json.number.int64`       
			// `godoc` tool; serve docs per HTML @ localhost (see below).  
			env [VAR]   // print Golang Env.Vars.; all or VAR
			fmt         // run `gofmt` on package sources
			get [-d]    // DOWNLOAD [only, @ `-d`] and INSTALL packages and dependencies
			get ./...   // ... ALL dependencies!
			install     // COMPILE and INSTALL packages and dependencies (.exe @ $GOPATH/bin)
			list        // List the IMPORT path of the current package.
				-f '{{ .Name | printf "%14s" }}  {{ .Doc }}' ./... // List pkg name and documentation.
				-f '{{.GoFiles}}' ./...         // list all files to be compiled
				-f '{{ join .Imports "\n" }}' ./...  // List all imports (one per line).
				// ... All METHODs @ https://golang.org/pkg/cmd/go/internal/load/#PackagePublic  
			run         // COMPILE and RUN Golang program
				// RUN (your SERVER) as bkgnd proc; MAKE REQUESTS per cURL; KILL all
				$ (go run .) & curl localhost:8080/{a,b,c}; killall go
			test -v -count=1 ./pkg1/...  // TEST packages; finds and runs all tests under package ./pkg1
			// Filter tests per test name, per RegEx 
			test -v -count=1 -run=Foo ./pkg1/pkg2  // Runs `TestFoo` function @ pkg2 
			test -bench // benchmarking
			test -benchmem -bench=EncodeSecret -count=1 ./kit // per test type, per func name
			version     // print Golang VERSION
			vet         // run static analysis on packages; reports "errors" that may compile.
				go tool vet help
				go vet ./... // All analysis on all packages
				go vet -assign=true -json=true ./... 

			fix         // update pre- go1 code to post- go1  

			// Remove package remnants (say, before deleting its source root dir)
			go clean -i foo/bar 
			go clean -i -n foo/bar  // dry run; does nothing but show 
			go clean -cache     // FAILs to clean @ ~/.cache/go-build/
			go clean -cache -modcache -i -r // Cleans @ ~/.cache/go-build/  (but hangs @ WSL)

			go help [COMMAND]   // for more information about a command.
			go fmt foo.go       // format source code per go spec [tabs]; alias for `gofmt`
			gofmt -w pkgName    // formats the whole project, overwriting the files.

			goimports           // integrates w/ code editors; automatically handles package imports
			                    // https://godoc.org/golang.org/x/tools/cmd/goimports

		go ACTION [PACKAGES]    // PACKAGES is a LIST of IMPORT PATHs
		// The Golang tool command searches for SOURCE code locally @ BOTH locations:
			$GOROOT/src  $GOPATH/src
		// So, use RELATIVE PATHs, as with `import`; "golang.org/x/tour/gotour", "fmt", ...

	// DOWNLOAD (to GOPATH)
		go get -u -d ./...      // Download ALL module's DEPENDENCIES.
	// DOWNLOAD +BUILD +INSTALL (to GOBIN)
		git clone REPO_URL   // Clones repo to ./<REPONAME>
		go get -u ./...      // Download & install ALL module's DEPENDENCIES.

	// UPGRADE all dependencies of entire MODULE
		go get -u -t -d -v ./...
		go mod tidy
		go mod vendor

	// GET :: (local|net) download and install
		go get -u PKGPATH  // Download & install; update from network
		// If per cloned repo ...

			// go get :: downloads source to ... 
			$GOPATH/src/PKGPATH 

			// @ Docker container ... 
			docker run golang go get -u github.com/$_USER/$_REPO/...
			docker commit $(docker ps -lq) $_NAME  // create image $_NAME from last-executed container
			docker run $_NAME foo bar              // run it

		// OPTIONs 
		go get [-u -f] [-d] [-fix] [-insecure] [-t] [build flags] [packages]
			// -u may FAIL @ cmd, so use mintty (Git-for-Windows) 
			-u // sans arguments, now only upgrades CURRENT PACKAGE's direct and indirect dependencies; no longer examines entire module.
			-u ./... // from module root upgrades all MODULE's direct and indirect dependencies; now excludes test dependencies.
			-u -t ./... // is similar, but also upgrades test dependencies.
			// sans -u, DEFAULT BEHAVIOR is to UPDATE per LOCAL only, NOT per network.
			// `-u` FAILs @ cmd-native (sometimes), so use Git-for-Windows (mintty)
			-f    // force NO VERIFY of source repo checkout
			-d    // download only; do NOT install
			-t    // also download test pkgs
			// -m is no longer supported; use -d

			// PREPENDING of BUILD DIRECTIVES (Golang super-secret, unreferenced)
			// to build per OS & ARCH (CPU), e.g., for linux on 64-bit Arm, from windows.  
			GOOS=linux GOARCH=arm64 go get -u PKGPATH

	// INSTALL 
		go install pkgPath/pkgName  // binary created @ `$GOBIN/pkgName.exe`
		// if `$GOBIN` unset, then defaults to `$GOROOT/bin`

	// COMPILE & RUN @ TMP`
		go run . 
		go run -a -mod=mod . // Force rebuild; do NOT use existing artifacts
			// `go help cache` WRONGFULLY claims:
			// The build cache correctly accounts for changes to Go source files,
			// compilers, compiler options, and so on: cleaning the cache explicitly
			// should not be necessary in typical use.

		// IF ONE source FILE (sans dependencies)
			go run absPATH/pkgName/fileName.go  // creates & runs binary @ TMP
		// ELSE MUST setup entire Golang env; all env-vars and rigid directory structures

	// COMPILE (BUILD)
		go build [-o output] [-i] [build flags] [packages]
		// https://golang.org/cmd/go/#hdr-Compile_packages_and_dependencies

		// PATH, `pkgPath/pkgName`, is RELATIVE to `$GOPATH/src/`
		go build pkgPath/pkgName    // binary created @ `$PWD/pkgName.exe`
		// if @ pkg dir 
		go build pkgName.go         // binary create @ `$PWD/pkgName.exe`
		// run ... 
		./pkgName [arg1 arg2 ...]   // run @ `PWD`
		// ALL binaries, but DO NOT USE (UNRELIABLE; may do nothing.) 
		go build ./...  // brittle/quirky; use separate build commands per binary. 
		// Vendoring 
		go build -mod vendor .
		// Name of the binary file 
		go build -o NAME .

		// PER OS / ARCH
		GOOS=Windows go build .  // Compile to binary for Windows (from a Linux machine).

		// +build  
		// BUILD CONSTRAINTs a.k.a. BUILD TAGs  https://golang.org/pkg/go/build/#hdr-Build_Constraints
		// MUST be ABOVE `package ...` clause 
		// MUST be followed by EMPTY LINE 
		// E.g., 

			// +build ignore

				// To exclude file from build (any other unsatisfied word will work as well; “ignore” is conventional.)

			// +build linux,386 darwin,!cgo

				// Corresponds to the boolean formula:
				// (linux AND 386) OR (darwin AND (NOT cgo))

			// +build linux darwin
			// +build 386

				// Corresponds to the boolean formula:
				// (linux OR darwin) AND 386

			// Constraint(s) per FILE NAME SUFFIX 
				*_GOOS
				*_GOARCH
				*_GOOS_GOARCH
				// E.g., 
					foo_windows_amd64.go

		// BUILD PER PLATFORM
			// GOOS Env. Var. :: per OS/MACHINE
			
				go build .                          // Linux; ELF 64-bit LSB
				GOOS=windows go build .             // windows|darwin|openbsd|freebsd
				GOOS=windows GOARCH=386 go build .  // Win32-bit
				
				file main.exe                             // SHOWS for which machine-code
			
			// Two mechanisms; use both
				// 1. BUILD RESTRICTION; name the file with the build restrictuion 
					foo_${GOOS}.go 
					// E.g., 
						/foo
							foo.go
							foo_windows.go
							foo_linux.go
							foo_darwin.go 
				// 2. BUILD DIRECTIVE; add it to top of source file, ABOVE `package ...`
					`// +build freebsd linux netbsd openbsd solaris dragonfl`

	// DOC
		go doc PKG [IDENTIFIER]  // Show PKG documentation [Print code @ IDENTIFIER]

	// MODULES :: "versioned Go modules" (MODULE MODE)  
		// Wiki  https://github.com/golang/go/wiki/Modules  
		// Doc   https://golang.org/ref/mod 
		// Blog  https://blog.golang.org/using-go-modules   
		// For VERSIONING :: The successor to dep > vgo > ... . 
		go mod init [PRJ_ROOT_NAME]// run mod commands @ TOP LEVEL of pkg ONLY 
			// E.g., 
			go mod init "foo.com/prj3" //... typically a GitHub repo
		// 'go.mod', 'go.sum' should only be @ TOP LEVEL, 
		// REGARDLESS of any other 'main.go' at any other subdirectories 

		// UPGRADE all dependencies of entire MODULE
		go get -u -t -d -v ./...
		go mod tidy
		go mod vendor

	        download    // download modules to local cache
	        edit        // edit go.mod from tools or scripts
	        graph       // print module requirement graph
	        init        // initialize new module in current directory
	        tidy        // add missing and remove unused modules
	        vendor      // make vendored copy of dependencies
	        verify      // verify dependencies have expected content
	        why         // explain why packages or modules are needed

		// NOT YET ready for production @ go1.11, go1.12
		GO111MODULE=auto // default setting; does NOT show up @ `go env` (go1.11.4)
		// - If OUTSIDE of GOPATH; needn't set GO111MODULE=on
		// - Some projects do NOT build WITH module mode.
		// - Some projects do NOT build WITHOUT module mode.
		export GO111MODULE=on  // manually activate MODULE MODE  
		go mod init [NAME]     // @ package root; creates `go.mod`, `go.sum` file 
		go mod tidy            // Adds/Deletes deps, as required per `import` stmnt
		go mod vendor          // Download all dependencies into `/vendor` dir
		go get -u ./...        // Update all deps to latest versions.
		go list -m all         // List all deps
		go list -m -versions pkgName // List all versions
		go get pkgName@v1.3.1  // Get specified version; defaults to `@latest`
		go build ./...         // Build the module 
		go test -v ./...       // Test the module (verbosely) as configured (See TESTING, below)
		go test -count=1       // Prevent cacheing
		go test . -run TestFuncName  // Run specified test @ current pkg
		go test all            // +tests for all direct and indirect DEPENDENCIES

		// PUBLISH a VERSIONed PKG
			git tag v0.1.0  // v{MAJOR}.{MINOR}.{PATCH}
			git push origin v0.1.0

			// VGO :: Versioned Golang MODULEs (2018)   
			// https://github.com/golang/go/wiki/vgo  
				vgo  // ORIGINAL command/name; 
				// Was drop in replacement for `go` tool to handle pkg versioning.
				// DEPRICATED; use `go` tool with MODULE MODE enabled:
			export GO111MODULE=on  // MODULE MODE :: "versioned Go modules"
			go ...  // ... tools now function in MODULE MODE 

			cat go.sum  // See versions; IF `v0.0.0`, THEN "untagged"; update ...
			go get pkgPath // Update; if unversioned, will get latest.
			/*
				DEP vs. MODULEs (2018-12)  
				Module support is in active development; 
				NOT yet ready for production.
				USE `dep` for any production workloads.
			*/

	// DEP TOOL :: Golang DEPENDENCY MANAGEMENT
	// Precusrsor to MODULEs; almost DEPRICATED; try to use modules 
		// https://tutorialedge.net/golang/an-intro-to-go-dep/#dep-init
		dep init // Create new project
			init|status|ensure|prune|version

			Gopkg.toml // specify dependencies/versions
			Gopkg.lock // snapshot of project’s dependency graph; series of [[project]] stanzas.
			./vendor/   // dependencies store 

		// ENSURE :: to ADD new package(s); that is, dependencies 
		dep ensure -add 'github.com/foo/bar' 'github.com/another/project' ...
		// ENSURE :: to UPDATE 
		dep ensure -update -n // DRY RUN 
		dep ensure -update   // all, for real
		dep ensure -update $_PKGPATH // one dependency/package
		// Update a package to a SPECIFIC VERSION 
		dep ensure -update $_PKGPATH@$_VERSION
		// E.g., gorilla/mux@1.0.0, ...
		dep ensure -update github.com/gorilla/mux@1.0.0

	// VENDORING; VENDOR DIRECTORIES  https://golang.org/cmd/go/#hdr-Vendor_Directories
	// Depricated; use MODULEs
		// EXTERNAL dependencies are downloaded by Golang tool 
		// to subdir of `vendor`, under `pkgPath` ROOT: 
		`$GOPATH/src/pkgHost/pkgPath/vendor/ahost.com/external/...`
		// OMIT PREFIX,`.../vendor/`, at `import` of such vendor packages:
		import (
			"strings"
			"ahost.com/external/extPkg1"
		)
		// Some include `vendor.json` file of all such packages, @ `.../vendor/`:
			...
			"package": [
					{
						"branch": "master",
						"importpath": "ahost.com/external/extPkg1",
						"path": "/extPkg",
						"repository": "https://ahost.com/external",
						"revision": "1e77c0103821b9340539b6776727195525381532"
					}, 
			...
		go build -mod vendor  // Else go build IGNOREs vendoring 

	// ERRCHECK :: Show SILENT ERRors 
	go get -u github.com/kisielk/errcheck
	errcheck  // instead of `go run .`

	// GODOC @ CLI :: DOCumentation
		godoc [-src] pkgPath/pkgName [funcName]  // -src shows source code
		godoc -http :1234  // @ localhost:1234; ALL pkgs @ GOROOT available

	// GENERATE  https://blog.golang.org/generate  
		// https://golang.org/cmd/go/#hdr-Generate_Go_files_by_processing_source
		// Run command(s) programmatically; per EXCLUSIVE directives written into a comment.
		// Those commands can run any process, but intent is to create/update (*.go) SOURCE code.
		// Runs EXCLUSIVELY by invoking `go generate ...` at the command line.
		go generate [-run regexp] [-n] [-v] [-x] [build flags] [file.go... | packages]
		// That Golang tool command scans for its (exclusive) directives in Golang source files
		// Its EXCLUSIVE DIRECTIVEs:

			//go:generate COMMAND ARGUMENTs...

		// OR

			//go:generate -command NAME COMMAND ARGUMENTs...

		// ... which specifies it's FOR REMAINDER OF THIS SOURCE FILE only; 
		// `NAME` is used to create ALIASES or to handle multiword generators.

		// Auto-inserts the comment below into the generated source code:
		// Code generated .* DO NOT EDIT\.$

		// Note that `go:generate` directive(s) are NOT invoked by ANY OTHER Golang tool; 
		// NOT by `go build ...`, `go run...`, `go install ...`, ... NONE of them.


	// TESTING; TEST PACKAGES  https://golang.org/cmd/go/#hdr-Test_packages
	// https://github.com/golang/go/wiki/CodeReviewComments#useful-test-failures
	// Prints STACKTRACE to STDOUT
		go test            				// test
		go test -bench=.   				// benchmark
		go test . -run TestFuncName  	// Run specified test @ current pkg

		// Run NO TESTs; only BENCH, longer, + memory allocations 
		go test -run none -bench . -benchtime 3a -benchmem
		
		go test [build/test flags] [packages] [build/test flags & test binary flags]
		go test -bench=. 				// BENCHMARKing  https://tutorialedge.net/golang/benchmarking-your-go-programs/ 
		go test -benchmem -bench=SubjectFunc -count=1 ./kit //... Note NOT -bench=BenchmarkSubjectFunc
		go test -bench=. | grep 'fatal error'
		go test -race   				// RACE CONDITION testing
		go test -race | grep 'WARNING: DATA RACE'
		go test -v ./... 				// verbose; '=== RUN ...', '--- PASS: ...'
		
		// COVERAGE (+HTML report showing % coverage per code)
		go test -cover -coverprofile=coverage.out ./...  // or pkgPATH to test
		//... test all in pkg @ pkgPATH, from project root
		go tool cover -html=coverage.out 
		//... open in browser; covered @ green; uncovered @ red

		// TESTFILE NAMEs '<foo>_test'
		/pkgname
			pkgname.go
			pkgname_test.go

			// E.g., @ `/pkname.go`
			func Foo(arg1 *aT,...) {... return good, bad}
			// @ `/pkgname_test.go`
			func Test_Foo(t *testing.T) {

			if got != tt.want {  // idiomatic
				t.Errorf("Foo(%q) = %d; want %d", tt.in, got, tt.want) 
				// or `t.Fatalf`, if test can't test anything more past this point
			}

			// ... or
			result, err := Foo(&param1,...)
			if err != nil {
				t.Errorf("FAILed @ Foo(): %s", err)
			}
			if anotherTest(result) == 0 {
				t.Error("Blah blah was bad.")
			} 
		}

		// Table-driven Testing     https://tutorialedge.net/golang/intro-testing-in-go/#table-driven-testing
		    var tests = []struct {
		        data int
		        want int
		    }{
		        {2, 4},
		        {-1, 1},
		        {99999, 100001},
		    }
			for _, test := range tests {
				if got := TheSubject(test.data); got != test.want {
					t.Error("TheSubject()\n\twant: %v\n\tgot:%v\n",test.want, got)
				}
			}

		// Testdata dir for Testing  https://tutorialedge.net/golang/advanced-go-testing-tutorial/
		// @ go/src/archive/tar/testdata

		// MOCK HTTP SERVER is included in Go Standard Library  https://golang.org/pkg/net/http/httptest/ 
		// https://tutorialedge.net/golang/advanced-go-testing-tutorial/#mocking-http-requests  

		// TDD example  https://github.com/quii/learn-go-with-tests/blob/master/select.md#problems

		// Differentiate btwn UNIT and INTEGRATION tests  https://tutorialedge.net/golang/advanced-go-testing-tutorial/#differentiate-your-unit-and-integration-tests

		// BENCHMARKing (@ VS Code)
		go.exe test -benchmem -run=^$ github.com\f06ybeast\md2html -bench ^(BenchmarkMdHTML)$

		goos: windows
		goarch: amd64
		pkg: github.com/f06ybeast/md2html
		BenchmarkMdHTML-4   	    2000	    841499 ns/op	  100465 B/op	     404 allocs/op
		PASS
		ok  	github.com/f06ybeast/md2html	1.814s
		Success: Benchmarks passed.

		// Test if any two vars are the same
		reflect.DeepEqual 
		func DeepEqual(x, y interface{}) bool
		// https://golang.org/pkg/reflect/#DeepEqual
		// https://github.com/quii/learn-go-with-tests/blob/master/arrays-and-slices.md
		func TestSumAll(t *testing.T)  {
			got := SumAll([]int{1,2}, []int{0,9})
			want := []int{3, 9}
			if !reflect.DeepEqual(got, want) {
				t.Errorf("got %v want %v", got, want)
			}
		}

// COMMENTs; this for single line comment.
/*
	This for Multi-line comment.

	PACKAGE COMMENT: a block comment PRECEDING the PACKAGE CLAUSE; EVERY PACKAGE SHOULD HAVE ONE; appears first on `godoc` page and should set up the detailed documentation that follows.  https://golang.org/doc/effective_go.html#commentary
*/

// IMPORT PATHs  https://golang.org/doc/code.html#ImportPaths
/*
	Import Path UNIQUEly identifies a PACKAGE; its location inside a WORKSPACE or 
	REMOTE REPOSITORY. E.g., packages from STANDARD LIBRARY: "fmt", "net/http", ...  

	BASE PATH
		Workspace packages must have a BASE PATH that is unlikely to collide with 
		future additions to the standard library or other external libraries; use root 
		of source repository as your [local] base path, e.g., `github.com/uzer`; don't need 
		to publish your code, but it's a good habit to organize your code as if you will publish 
		it someday; can choose any arbitrary path name, as long as it is unique to the standard 
		library and greater Golang ecosystem.  https://golang.org/doc/code.html#Workspaces

		The Go Tool command: `go ACTION [PACKAGES]` searches for PACKAGES [list] 
		@ both `$GOROOT/src` and `$GOPATH/src`, so RELATIVE PATHs are typically used; 
		"fmt", "xApp" , "golang.org/x/tour/gotour", "github.com/username/reponame", ...  
*/
	import (
		"github/foo/bar"
		cfg "some/pkg/configuration"  // Alias; usage: `cfg.anIdentifier`
		_ "unused"  // Blank alias allows compile though UNUSED 
		"../../foo" // Rel-path okay ONLY if OUTSIDE Workspace ($GOPATH/src) 
	)

// PACKAGE DOCs 
	// STANDARD LIBRARY @ https://godoc.org/ ... per pkgName 
	// functions are listed @ "Index" per RETURN TYPE or RECEIVER TYPE, 
		// e.g, @ `net.Listen` FUNC is @ `Listener` TYPE
		type Listener
			func Listen(network, address string) (Listener, error)
			... 

// PACKAGE CLAUSE
	package NAME
	/*
		The first statement in a Go source file; `NAME` is the package's default name for imports; all files in package must use same name; CONVENTION is to use its folder name, e.g., package imported as "crypto/rot13" should be named rot13

		Packages [Go source files] are imported per rel-path-to-folder, but referenced in the code per package clause.

		Package names need NOT be unique [across all packages linked into a single binary], but import paths MUST be unique.
	*/
	// E.g., @ path ...
		foo/bar/
			bar.go              // convention; fileName is folderName
				package bar     // convention; pkgName is folderName
			baz.go              // if more than one file in folder, then need other name(s)
				package quix    // okay, but convention is `package baz`
			qix.go
				package quix    // okay to have 1 pkg spread out across multiple files
		foo/app/
			main.go             // covention; `main.go` OR `app.go`
				package main    // REQUIREd of the executable; sets the entry point
				import foo/bar  // IMPORTED per PATH [to its folder]
				import foo/baz
				func main() {
					fmt.Println(quix.someFuncOrExportedVar) // REFERENCED per PACKAGE CLAUSE

	// `main` is a special name; NOT a package-name; ENTRY POINT for every Golang executable. 
		package main  // `main(){}` is the MAIN GOROUTINE 

// NAMES  https://golang.org/doc/effective_go.html#names
	// Golang has only 2 types of visibility: Exported vs. Unexported
	// names with UPPERCASE 1st letter are EXPORTed, else NOT.
	// for multi-word names, use `MixedCaps` or `mixedCaps` rather than underscores

	// PACKAGE NAME becomes an ACCESSOR for the contents
		import "bytes"  // convention is LOWERCASE ALPHA 
		bytes.Buffer    // usage, so keep package names short  

// IMPORTing PACKAGEs 
// Golang tools AUTOMATICALLY FETCH all dependencies per URL path.  

	// STANDARD LIBRARY; omit path prepending pkgName 
		import "pkgName"  // Go tools auto-search @ `golang.org/pkg/...`

	// OTHER `golang.org` LIBRARIES; not in standard library because 
	// pkg is UNDER DEVELOPMENT or RARELY NEEDED: 
		import "golang.org/x/pkgName"  // `golang.org/x/...`

	// EXTERNAL PACKAGEs 
	// E.g., `GolangTraining` package per its GitHub repo (URL path).   
		import "github.com/GoesToEleven/GolangTraining" 

	// FACTORED import declaration 
		import (
			"fmt"         // sans path if @ Go STANDARD LIBRARY; https://golang.org/pkg/fmt/
			m "math"      // a RENAMING IMPORT; Math library given LOCAL ALIAS `m`.
			_ "image/png" // a BLANK IMPORT; register PNG decoder; never using it directly
		)

// DATA STRUCTUREs 
		// ARRAYs, SLICEs, MAPs
		// Mechanical Sympathy 

// KEYWORDs
	break        default      func         interface    select
	case         defer        go           map          struct
	chan         else         goto         package      switch
	const        fallthrough  if           range        type
	continue     for          import       return       var

// BUILTINs  https://golang.org/src/builtin/builtin.go 
	// FUNCTIONS builtin (signatures)
	func append(slice []Type, elems ...Type) []Type
	func copy(dst, src []Type) int
	func delete(m map[Type]Type1, key Type)
	func len(v Type) int  // elements, per type; if `nil`, then `0`
	func cap(v Type) int  // max elements, per type; if `nil`, then `0`
	func make(t Type, size ...IntegerType) Type  // SLICE, MAP, CHAN (only) 
	func new(Type) *Type  // pointer; allocates memory and points to it. 
	func real(c ComplexType) FloatType 
	func imag(c ComplexType) FloatType 
	func complex(r, i FloatType) ComplexType 
	func close(c chan<- Type)  // should be executed BY SENDER (ONLY)
	func panic(v interface{})  // stops CURRENT goroutine, returning panic to caller 
	func recover() interface{} // manage post panic 
	func print(args ...Type)   // for debug ONLY; else use `fmt.Printf` 
	func println(args ...Type) // for debug ONLY, else use `fmt.Println` instead 
	type error interface {     // `nil` value representing no error
		Error() string 
	} // ... + other builtins ... (see link above)

// OPERATORS and PUNCTUATION  
	// https://golang.org/ref/spec#Operators 
	+    &     +=    &=     &&    ==    !=    (    ) 
	-    |     -=    |=     ||    <     <=    [    ]
	*    ^     *=    ^=     <-    >     >=    {    }
	/    <<    /=    <<=    ++    =     :=    ,    ;
	%    >>    %=    >>=    --    !     ...   .    :
		 &^          &^=
	// `&&` and `||` have SHORT-CIRCUIT BEHAVIOR; right operand NOT evaluated IF left is true 

	// BINARY OPERATORs 
		 &   // bitwise AND
		 |   // bitwise OR
		 ^   // bitwise XOR
		 &^  // bit clear (AND NOT) 
		 <<  // left shift   X<<N is multiply by Nth power of 2 
		 >>  // right shift  X>>N is divide   by Nth power of 2
			// e.g., SHIFT operations ...
				1 << 10  // 1024 
				1 << 3   // 8
			
			// XOR byte 
			x := byte(3); y := byte(5) 
			fmt.Printf("%3b,%3b,%3b\n",x,y,(x ^ y)) //11,101,110
			//  XOR []byte @ https://sourcegraph.com/github.com/hashicorp/vault/-/blob/helper/xor/xor.go#L8
		
		// All binary operators support the short-hand compound assignment form
		x = x & 0xF0  // clear last 4 LSB
		x &= 0xF0     // equiv.

		// Quite useful when doing MASK (BITMASK) techniques
		// Query per AND, Toggle per XOR
		// Mask :: https://en.wikipedia.org/wiki/Mask_(computing)
		// https://github.com/russross/blackfriday-tool/blob/master/main.go 

// SCOPE 
	// Golang is "lexically scoped", sort of. A macabre rule whereof 
	// inner (child) functions have NO ACCESS to outer (parent) function 
	// variables, yet sometimes they do, e.g., if the inner is a closure;
	// `func() { foo := 2; return func(){... foo is visible here ...}...}`.
	// 
	// Such bizarre scope rules encourage (necessitate) "global" declarations,
	// exposing such vars to all files of the folder. Also, a folder is called 
	// a "package", but only to describe the aforementioned rules. That is, 
	// a folder is NOT a package in other Golang contexts.

	// Zero documentation on how to write programs under such a
	// labyrinth of inexplicable constraints. Golang's brittle typeing rules 
	// render function signatures rigid, so often can't inject such variables 
	// as an added parameter without rewriting an entire universe of code. 
	// Thus, globals everywhere. 

	// Golang still beats the other, evermore moronic, languages.

// BLOCK / STATEMENT LIST  https://golang.org/ref/spec#Blocks
	Block = { StatementList } // blocks NEST and influence scope.
	StatementList = { Statement; } 
	// Curly brackets DEFINE a NEW STACK; a NEW level of SCOPE.
	id := 10
	{
		id := 20
		fmt.Printf("Id: %d\n", id)  // 20
	}
	fmt.Printf("Id: %d\n", id)      // 10  

// BASIC TYPES
	// BOOLEAN; true, false, !true, !false, true || false , true && false 
		bool 
	// STRING; immutable sequence of bytes; visible as sequence of runes (characters); 
	// typically UTF-8 & human readable, but needn't be; enclosed in "DOUBLE-QUOTES" or `BACK-TICKS` 
		string // a two word variable; a pointer (to its first byte) and the number of bytes
	// NUMERIC types  https://golang.org/ref/spec#Numeric_types  
		int  int8  int16  int32  int64           // signed INTEGERs 
		uint uint8 uint16 uint32 uint64 uintptr  // unsigned INTEGERs 
		byte  // uint8 alias; 
		rune  // int32 alias; ONE CHARacter; 1 Unicode Code Point; 1 glyph; in 'SINGLE-QUOTES'
		float32 float64       // FLOAT 
		complex64 complex128  // COMPLEX 

		// Use `int`, sans precision, unless necessary, to exploit MECHANICAL SYMPATHY;
		// optimizes per-architecture variable size.
			int
		
		// DECLARE AND INITIALIZE to ZERO-VALUE 
			var x int 

// METHOD SETS
	/*
		A type may have a method set associated with it. 
		The method set of an INTERFACE type is its interface. 
		The method set of any other type T consists of all methods declared with RECEIVER type T. 
		The method set of the corresponding POINTER type *T is the set of all methods declared with RECEIVER *T or T 
		(that is, it also contains the method set of T). 

		Further rules apply to STRUCTS containing embedded fields.
		Any other type has an empty method set. 
		
		The method set of a type determines the interfaces that the type IMPLEMENTS 
		and the methods that can be called using a receiver of that type. 
	*/

// UNTYPED
	nil  // ZERO VALUE for pointers, interfaces, maps, slices, channels, and functions.
	true false  // untyped boolean VALUEs 
	iota        // untyped int VALUE; "predefined identifier"; 
	// IOTA (ENUMERATOR)  https://yourbasic.org/golang/iota/
	// `iota` resets to `0` at each `const` keyword; AUTO-INCREMENTS thereafter; 
	// `iota` allows more concise constant declarations. E.g., 
		const ( 
			_    = 1 << (10 * iota)  // ignore first; @ iota = 0 
			KiB
			MiB
			GiB 
			...
			YiB
		) 
		fmt.Println(KiB,float64(GiB),float64(YiB))  //=> 1024 1.073741824e+09 1.2089258196146292e+24

		// MASK (BITMASK) :: Used to efficiently Store/Test/Add/Del a set of  mutually exclusive things (e.g., options) in ONE VARIABLE.
		const (
			EXTENSION_NO_INTRA_EMPHASIS  = 1 << iota 
			EXTENSION_TABLES                 
			EXTENSION_FENCED_CODE            
			EXTENSION_AUTOLINK               
			//...
			commonExtensions = 0 |
				EXTENSION_NO_INTRA_EMPHASIS |
				EXTENSION_TABLES |
				//...
		)
		
// ENUMERATED TYPES (Enumerated Constants) a.k.a."enums"; use `iota` ...  
	// https://golang.org/doc/effective_go.html#constants
	type Color int64 // create the "enum" type
	const ( // list of all possible "enum" values
		RED Color = iota
		BLUE
		GREEN
		WHITE
		BLACK
	)

// SPECIAL VALUES 
	+Inf, -Inf  // infinities, +/-; representing excessive magnitude & division by zero. 
	NaN  // "not a number"; result of dubious math operations, e.g., `0/0` or `Sqrt(-1)`. 

// TYPE DECLARATIONs
	// binds an identifier, the type name, to a type
	type Cat string    // declare new type, `Cat`, bound to basic type `string`
	var c Cat          // declare variable `c` of type `Cat`; so `c` is a `string`
	type Cat struct{}  // declare new type, `Cat`, bound to type `struct`
	var err error      // declare variable `err` of type `error` 

// CONSTANTs  https://golang.org/ref/spec#Constants ; "... just numbers." -- Rob Pike
	// Unlike variables, Golang's constants are like regular numbers.  https://blog.golang.org/constants
	// Numeric constants represent exact values of arbitrary precision and do not overflow. 
	// typed OR untyped; if untyped, IMPLICITLY TYPED PER USE @ operand expression or var assignment; 
	// UNTYPED constants have HIGHer PRECISION (at least 256 bits); require fewer conversions.
	const Pi = 3.1415926535897932384626433832795028841971693993751058209749  // NOT `:=` syntax.

	// `const` also used for `iota` and its "enums" construct; see "UNTYPED" section above.

// VARIABLEs  https://golang.org/ref/spec#Variables
/*  
	Golang LINGO: "level" is "scope", e.g., "function level" vs. "package level"

	NAMES should be short; especially for local vars with limited scope. Prefer `c` to `lineCount`; `i` to `sliceIndex`; BASIC RULE: the further from its declaration that a name is used, the more descriptive the name must be. For a method RECEIVER, ONE OR TWO LETTERS is sufficient; idiom is first letter of its type.  
*/
	// VARIABLE DECLARATIONS: NAME preceeds TYPE; grammatical;
	// Read left-to-right; 'expression syntax' vs. C's type-syntax
		var x int      // DECLARATION, i.e., "variable `x` is of type `int`"
		               //   `x` is INITIALIZED to its type's ZERO VALUE.
		x = 3          // ASSIGNMENT; must be of delcared type.

		x := 3         // SHORT STATEMENT a.k.a. SHORT DECLARATION; type is IMPLICIT 
		               //   ONE statement that DELCAREs AND ASSIGNs; @ func level ONLY.

		var x = 3      // DECLARE AND ASSIGN; type INFERRED from right-hand side [RHS]; IMPLICITly 
		var x int = 3  // okay, but REDUNDANT, defining type explicitly and implicitly.
		var xMax uint64 = 1<<64 - 1  // here, type would be ambiguous, if not specified explicitly

		// ZERO-VALUEs; assigned PER TYPE
			""      // strings
			0       // numeric types; int, uint, int32, ..., byte, rune, uintptr,...
			false   // boolean types
			nil     // pointers, interfaces, maps, slices, channels and function types
					// (All complex types have zero-value of `nil`.) 

		// Type SIZEs / ALLIGNMENTs / (structure) PADDING 
			// Variables are padded, per architecture, to fit inside a Word boundary
			// https://go101.org/article/memory-layout.html
			// Micro-optimize (minimize) padding by ordering struct fields from largest to smallest.
			// But only if memory profile suggests it's a issue.

		// when RHS is UNTYPED NUMERIC CONSTANT, var is TYPED PER PRECISION of RHS
			i := 42            // int
			f := 3.142         // float64
			g := 0.867 + 0.5i  // complex128

	// DEPENDENCIES are RESOLVED first; so out-of-ORDER is okay ...
		var a = b + c
		var b = f()
		var c = 1
		func f() int { return c + 2 }    

	// REdeclaration / REassignment  https://golang.org/doc/effective_go.html#redeclaration
	// @ func return of multiple vars w/ ONE NEW var, then 2nd var can be REdeclaration / REassignment 
 		f, err := os.Open(name)  // `err` is redeclared/reassigned; `f` must be NEW 
		d, err := f.Stat()       // `err` is redeclared/reassigned; `d` must be NEW 

	// TUPLE ASSIGNMENT or DECLARATION; use only when helpful logically, e.g., fibonacci func 
		var a, b, c = "foo bar", false, 7.5  // IMPLICITly typed, per INITIALIZERs 
		var a, b, c bool                     // if ALL of ONE TYPE
		// DECLARATIONs can be FACTORED into BLOCKS; `var`, `const`, `import`
		var (
			home   = os.Getenv("HOME")
			user   = os.Getenv("USER")
			gopath = os.Getenv("GOPATH")
		)
		x, y = y, x  
		a[i], a[j] = a[j], a[i] 

		// @ SHORT DECLARATIONS [@ functions ONLY];
		a, b, c := "foo bar", false, 7.5     // type(s) INFERRED per INITIALZERs 

	// SINGLE-QUOTE escaped can be EITHER 1 CHAR or 1 INT (Unicode Code Point)
		'$', '\u0024', '\044', '\x24', 36   // LITERAL, UNICODE, OCTAL, HEX, DEC

	// TYPE CONVERSION / type COERSION (when var set per type-conversion) 
		T(x)  // only some conversions are allowed;

		float64(65)     // float64(int)  65
		string(65)      // string(int)  "A"
		rune("A"[0])    // rune(uint8)   65
		rune('A')    	// rune(uint8)   65
		int32("A"[0])   // int32(uint8)  65
		int8("A"[0])    // int8(uint8)   65
		byte("A"[0])    // uint8(uint8)  65
		byte('A')       // uint8(int32)  65  // many runes will fail; all beyond ASCII (uint8)
		string('A')     // string(int32) "A"
		string('☧')     // string(int32) "☧"
		rune("A")       // FAIL: cannot convert "A" (type untyped string) to type rune
		rune('\u0041')  // 'A'

		// STRING to SLICE 
		[]rune("A")     // []int32{65}   [65]  
		[]int32("A")    // []int32{65}   [65]
		[]uint8("A")    // []byte{0x41}  [65]
		[]byte("A")     // []byte{0x41}  [65]

		[]rune("A☧")    // []int32{65, 9767}  [65 9767]
		[]int32("A☧")   // []int32{65, 9767}  [65 9767]
		[]uint8("A☧")   // []uint8(string)    [65 226 152 167]
		[]byte("A☧")    // []uint8(string)    [65 226 152 167]

		[]byte('☧')     // FAIL; cannot convert '\u2627' (type rune) to type []byte 

		// SLICE to STRING 
		string([]string{ "foo", "bar"}[1])  // string([]string)  "bar"
		string([]byte("foo")[1:3])          // string([]uint8)   "oo"
		string([]rune("foo"))               // string([]int32)   "foo"

		// STRINGs vs. RUNEs vs. BYTEs  
			string('\u2627')  // ☧     string 
			rune('\u2627')    // 9767  int32  (U+2627, '☧')
			byte('\u2627')    // "constant 9767 overflows byte" 
			[]byte('\u2627')  // "cannot convert '\u2627' (type rune) to type []byte"
			[]byte("\u2627")  // [226 152 167], []byte{0xe2, 0x98, 0xa7}, [U+00E2 'â' U+0098 U+00A7 '§'] 

			[]byte("☧")       // [226 152 167], []byte{0xe2, 0x98, 0xa7}, [U+00E2 'â' U+0098 U+00A7 '§'] 
			"☧"[0]            // 226, 0xe2, "â", U+00E2; most Unicode/UTF-8 characters EXCEED 1 byte 
			rune('☧')         // 9767, U+2627

			fmt.Printf("%x\n", rune('·')) // b7   : \u00b7
			fmt.Printf("%x\n", rune('•')) // 2022 : \u2022
			fmt.Printf("%x\n", rune('▸')) // 25b8 : \u25b8


			"A"[0]            // 65, 0x41, U+0041, 'A'; ACII subset of UTF-8 are all 1 byte/char
			'\u0041'          // 65       int32 (rune) 
			"\u0041"          // A        string 
			`\u0041`          // \u0041   string 

			string(65)        // string(int)   "A"
			string('A')       // string(int32) "A"
			rune('A')         // 65; int32 (rune); can represent ANY Unicode Code Point; ANY CHARACTER (glyph)
			byte(65)          // 65; int8  (byte); LIMITED to a small SUBSET of Unicode; ONE BYTE; 0-255 only
			[]byte("A")       // [65]
			[]byte("Abc")     // [65 98 99]  
			[]byte("Abc")[0]  // 65  

			// ... note use of SLICE LITERAL; also used to EMBED ASSETS (files) into go code
				b := []byte("\x1f\x8b ... \x0f\x00\x00")
				// E.g., embed a template (file) as type []byte 
				fooTemplate, err := ioutil.ReadFile("fooTemplate.gohtml") 

		// A Go STRING is an ARRAY of BYTEs; Go arrays, thus strings, are IMMUTABLE  

		// Unicode REPLACEMENT CHARACTER, '\uFFFD', '�'; generated on UTF-8 DECODE ERROR, whether decoding implicitly @ `range` loop, or explicitly @ call to `utf8.DecodeRuneInString`. This typically indicates upstream error/carelessness.

		// STRING INDEX ACCESS (array index access);  
			"big"[1]    // 105 uint8 (byte); index is per byte, NOT rune (character) 
		
		s[i:j] // SUBSTRING OPERATION; creates a new string of `j-i` BYTES; 
		// from BYTE @ index `i` up to, but not including, BYTE at index `j`
			"big"[1:3]  // ig string 
		
		len(s) // string length is in bytes, NOT runes  
			len("☧")    // 3  

		// 1 character (rune) is NOT necessarily 1 byte 
			s := "☧"   // one char
			fmt.Printf("%v %T, % X % T\n", s, s, []byte(s), []byte(s)) // ☧ string, E2 98 A7 []uint8
			fmt.Printf("%v %T, %X % T\n", s, s, []rune(s), []rune(s))  // ☧ string, [2627]   []int32
			s = s[0:1] // one byte 
			fmt.Printf("%v %T, % X %T\n", s, s, []byte(s), []byte(s))  // � string, E2     []uint8 
			fmt.Printf("%v %T, %X %T\n", s, s, []rune(s), []rune(s))   // � string, [FFFD] []int32 
		// string SIZE per TYPE  (storage size)
			s := "\u007A i\t☧"  //=>  z i	☧  
			fmt.Printf("Type: %T\tbits: %v\t% X\n",s, 8*len(s), s)               
			fmt.Printf("Type: %T\tbits: %v\t% X\n", []byte(s), 8*len([]byte(s)), []byte(s)) 
			fmt.Printf("Type: %T\tbits: %v\t%X\n", []rune(s), 32*len([]rune(s)), []rune(s)) 
			// Type: string    bits: 56    7A 20 69 09 E2 98 A7 
			// Type: []uint8   bits: 56    7A 20 69 09 E2 98 A7 
			// Type: []int32   bits: 160  [7A 20 69 9 2627] 

		// SUBSTRING | TRUNCATE 
			runes := []rune(strconv.FormatInt(time.Now().UnixNano(), 10)) 
			// 1568133245729678300
			ms := string(runes[10:]) 
			// 729678300

	// LITERALS
		// Integer  https://golang.org/ref/spec#Integer_literals
		17014118346, 0600, 0xBadFace, 0Xf06  // DEC, OCT, HEX, HEX examples  
		// Floating Point  https://golang.org/ref/spec#Floating-point_literals
			0., 72.40, 072.40, 2.71828, 1.e+0, 6.67428e-11, 1E6, .25, .12345E+5
		// Imaginary  https://golang.org/ref/spec#Imaginary_literals
			0i, 011i, 0.i, 2.71828i, 1.e+0i, 6.67428e-11i, 1E6i, .25i, .12345E+5i
		// String   https://golang.org/ref/spec#String_literals
			`literalString`  // RAW STRING literal; uninterpreted (UTF-8) chars
			"literalString"  // INTERPRETED STRING literal

				raw_string_lit         = "`" { unicode_char | newline } "`" .
				interpreted_string_lit = `"` { unicode_value | byte_value } `"` .

				// Thus inside a string literal 
				\377, \xFF  // represent 1 byte of value 0xFF=255
				ÿ, \u00FF, \U000000FF, \xc3\xbf  // represent 2 bytes, 0xc3 0xbf; UTF-8 char U+00FF.

		// Rune (int32)  https://golang.org/ref/spec#Rune_literals 
		// is an INTEGER value identifying ONE CHARACTER; ONE glyph (rune);  
		// ONE Unicode Code Point [UTF-8]  https://www.w3schools.com/charsets/ref_html_utf8.asp 

		// SINGLE-QUOTE escaped can be EITHER 1 CHAR or 1 VALUE (Unicode Code Point)
		'a'  // holds 1 byte (0x61) representing a LITERAL a; Unicode: U+0061, 0x61 
		'ä'  // holds 2 bytes (0xc3 0xa4) representing a literal a-dieresis; Unicode: U+00E4, 0xe4.

			'\a', '\b', '\f' ,'\n' ,'\r', '\t'  // some control chars; ASCII is subset of UTF-8 
			'$', '\u0024', '\044', '\x24', 36   // LITERAL, UNICODE, OCTAL, HEX, DEC; all of DOLLAR SIGN 
			'☧', '\u2627', '\U00002627', 9767   // LITERAL, UNICODE, UNICODE, DEC; all of CHI RHO 
		// The escaped Unicode are HEX digits; \uHHHH and \uHHHHHHHH
		// OCTal \nnn (3-digit) and HEX \xNN (2-digit) ESCAPEs represent ONE BYTE, 
		// thus are limited to a small SUBSET of UTF-8, so avoid if able; use \uNNNN instead. 

			// String vs. Rune LITERALS 
			// Unicode CODE POINT [UTF-8] [1-4 bytes]  
			var s1 = "\u2627"  // https://golang.org/ref/spec#String_literals
			var c1 = '\u2627'  // https://golang.org/ref/spec#Rune_literals

			fmt.Println(s1, string(c1))  //=> ☧ ☧ 
			fmt.Println(c1, []byte(s1))  //=> 9767 [226 152 167] 

			// CHARACTER [UTF-8]  [1-4 bytes] 
			var s2 = "☧"      // https://golang.org/ref/spec#String_literals
			var c2 = '☧'      // https://golang.org/ref/spec#Rune_literals

			fmt.Println(s2, string(c2))  //=> ☧ ☧
			fmt.Println(c2, []byte(s2))  //=> 9767 [226 152 167] 

		// COMPOSITE LITERALs
			// @ ARRAY, SLICE, MAP; keys (indices) are OPTIONAL, though 
			// if SANS keys, then ALL FIELDs INITIALIZEd and IN ORDER  
			// https://golang.org/ref/spec#Composite_literals 
				a := [...]string   {"foo", "bar"}      // ARRAY
				s := []string      {"foo", "bar"}      // SLICE
				m := map[int]string{1:"foo", 2:"bar"}  // MAP
				
			// byte SLICE LITERAL; used to EMBED STATIC ASSETS (files) into go code, 
			// and @ other TYPE CONVERSIONs
			// https://tech.townsourced.com/post/embedding-static-files-in-go/  
				fileData := []byte("\x1f\x8b ... \x0f\x00\x00")

			// @ STRUCTs; require 2 statements, unless ANONYMOUS ...
				type aStruct struct{ A, B string }  // struct TYPE declaration
				s := aStruct{A: "foo", B: "bar"}    // struct VAR short declaration; declared & initialized
				s := aStruct{}                      // as above, but assigned zero value(s) per field type

				// ANONYMOUS struct ( Cheaper + safer than `map[string]interface{}` ) 
				// Useful if used only @ one place, e.g., unmarshalling a web response.
				s := struct{ A, B string }{B: "bar"}      // 1st field IMPLICITly assigned; type + zero value
				s := struct{ A, B string }{"foo", "bar"}  // ALL, and ORDERed (required), if sans keys (indices)

					//  %v       %#v      ... comparing NAMED vs. ANONYMOUS ...
					//-------   -----------------------------------------------
					{foo bar}   main.aStruct{A:"foo", B:"bar"}                   // aStruct
					{foo bar}   struct { A string; B string }{A:"foo", B:"bar"}  // anonymous

				s := struct{}{}                           // empty struct

				health := struct {
					Service string `json:"service"`
					SVN     string `json:"svn"`
					Version string `json:"ver"`
					Built   string `json:"built"`
					Status  string `json:"status"`
					Host    string `json:"host"`
					Node    string `json:"node"`
				}{
					Service: c.meta.Service,
					SVN:     fmt.Sprintf("%12s", c.meta.SVN),
					Version: c.meta.Version,
					Built:   c.meta.Built,
					Host:    kit.GetHostname(),
					Node:    os.Getenv("HOSTNAME"),
				}

			// KEYs are also called FIELD NAMEs 

// ARRAYs  [val0 val1 val2 ... valN]  type [n]T
/*
	A fixed-length set of elements, all of ONE TYPE;
	LENGTH is PART OF ITS TYPE.  
	Type `[n]T` is an array of n values of type T.
	ZERO VALUE of elements is 0;
	passed by value, NOT by reference/pointer. 
	For C-like behavior and efficiency, pass a pointer to the array, or a slice of the array.
	Arrays are useful when planning the detailed layout of memory; can help avoid allocation,
	but primarily they are a building block for slices.
*/
	// CREATE per ARRAY LITERAL (a.k.a. COMPOSITE LITERAL)
		a := [...]string   {"foo", "bar"}      // ARRAY

	var a [3]string          // [3]string{"", "", ""}
	a[1] = "foo"             // set SECOND element
	fmt.Printf("%#v",a)      // [3]string{"", "foo", ""}
	fmt.Println(a[0], a[1])  // foo

	foo :=3
	bar := &foo
	primes := [5]int{7, *bar, 2} // array of 5 integers; SHORT DECLARATION
	fmt.Println(primes)          // [7 3 2 0 0]

	// RANGE over an ARRAY
		a := [...]string{"\u03a7", "\u03a1", "\u2627"}
		for key, val := range a {
			fmt.Printf("%v:%v, ",key, val)  //=> 0:Χ, 1:Ρ, 2:☧,
		}

	// SLICEs   [arrValN arrValN+1 ...]  type T

	/*
		MUTABLE REFERENCE to an UNDERLYING ARRAY, thus all ELEMENTS are of ONE TYPE; 
		wraps an array, but needn't explicitly create its underlying array; 
		golang handles that as necessary; assigning one slice to another refers both 
		to the same array; multiple slices can share the same underlying array and may 
		refer to overlapping parts of that arraya general, powerful, and convenient 
		interface to sequences of data; a dynamically-sized, 
		flexible view into the elements of an array.

		PASSED by value, but EFFECTIVELY by REFERENCE; 
		i.e., its underlying array is affected, globally; 
		changes to slice, at ANY SCOPE, modify its underlying array, 
		and affect all slices of that underlying array. 
		HOWEVER, operations on them require an assignment statement; 
		slices are NOT "pure" reference types; mutations may or may not
		persist without assigning, e.g., `s = f(s)`. 
		Exceptions are referred to as `IN-PLACE TECHNIQUES`.  

		*********************************************************************************
		PASS BY VALUE, `[]aStruct`, IF MODIFYING ONLY the VALUES OF the ELEMENTS, 
		neither the number nor position of its elements. Else, PASS BY POINTER `*[]aStruct`.
		That is, if you want the mutations performed on the slice to survive after the call.
		https://medium.com/swlh/golang-tips-why-pointers-to-slices-are-useful-and-how-ignoring-them-can-lead-to-tricky-bugs-cac90f72e77b
		*********************************************************************************
		func doTo(aa []aStruct) { ... mutate the slice PERSISTENTLY ... }

		Golang slices are much MORE COMMON THAN ARRAYS.

		Type `[n]T` is an ARRAY of n values of type T.
		Type `[]T` is a SLICE with elements of type T.
		
		Slice ZERO VALUE is `nil`; test `len(s)`, NOT `s`. 
		
		3 Components of a slice
			- Pointer: points to the 1st array element reachable through the slice; 
			           NOT necessarily the 1st element of the underlying array.
    		- Length: the number of slice elements; can NOT exceed slice capacity.
    		- Capacity: the number of elements between the start of the slice and the end of the underlying array.

		https://blog.golang.org/go-slices-usage-and-internals
	*/ 

	// Note access at slice of struct
		type A struct {
			a int
		}
		type B struct {
			C []A
		}
		x := B{}

		fmt.Println(x.C)
		fmt.Println(x.C[0]) // [] 
		//... panic: runtime error: index out of range [0] with length 0

	// CREATE (THREE WAYS)
	// 1. per `make()`; BEST WAY
		s := make(TYPE, LENgth [,CAPacity])
		a := make([]int, 5)     // len=cap=5;     [0 0 0 0 0]
		b := make([]int, 0, 5)  // len=0, cap=5;  []


	// 2. per STRUCT LITERAL syntax (a.k.a. COMPOSITE LITERAL); 'shorthand'
		s := []int{2, 3, 5, 7, 11, 13}  // len=6 cap=6 []int{2, 3, 5, 7, 11, 13} 
		s = s[:4]                       // len=4 cap=6 []int{2, 3, 5, 7}; :X is UP-TO AND INCLUDING
		s = s[2:]                       // len=2 cap=4 []int{5 7}; 'X:' is FROM X ONWARD
		s[1] = 999                      // len=2 cap=4 []int{5, 999} 
		s = s[:0]                    	// len=0 cap=4 []int{} 

	// 3. per EXISTING ARRAY 
		primes := [6]int{2, 3, 5, 7, 11, 13}    // array of 6 integers
		clone := primes[0:]                     // slice `clone` contains all els of array `primes` 
		var s []int = primes[1:4]               // slice; elements 1-3
		s := []int{3, 5, 7}                     // EQUIValent; SHORT DECLARATION
		fmt.Println(s)		                    // [3, 5, 7]
		s := primes[1:4]  // @ func; short statement equiv.

			// EMPTY int slice declaration
			var x []int                     // len=0 cap=0 []int(nil) 
			x[0] = 5                        // panic: runtime error: index out of range
			// EMPTY slice declaration 
			var t []string    // a `nil` slice value; idiomatic Go
			// NOT
			t := []string{}   // non-nil but zero-length

	// FULL SLICE EXPRESSIONs @ array, pointer to array, or slice
		s[low : high : max]  // 0 <= low <= high <= max <= cap(a) 
		// DEFAULTs
			low = 0; high = len(s) 

		s := []int{3, 5, 7}
		// all these are equivalent …
			s[0:3]
			s[:3]
			s[0:]   // "HALF-OPEN RANGE"; `[n:]`
			s[:]   // highlights that data type is slice, unlike simply using `s`
			s

	// LENGTH & CAPACITY of slice
		len(s)  // LENGTH; els in slice
		cap(s)  // CAPACITY; els of underlying array, starting from 1st el in SLICE 
		
		fmt.Printf("len=%d cap=%d %#v\n", len(s), cap(s), s) 

	// COPY per builtin; 
	// `src` overwrites `dst`; handles details; copies what fits if sizes differ;  
	//  slices may refer to the same underlying array, or they may even overlap 
	func copy(dst, src []Type) int  // signature 
		x := []int{77, 88, 99} 
		y := []int{1, 2, 3, 4, 5} 
		copy(y, x)  //  L/C (5/5)  []int{77, 88, 99, 4, 5} 
		fmt.Printf("L/C (%v/%v)  %#v\n", len(y), cap(y), y) 

	// INDEX ACCESS; slice of string (Go strings are arrays) 
		s2 :="foo bar"[1:3]  // oo, [U+006F U+006F], [157 157] 
		fmt.Printf("%s, %U, %o", s2, []rune(s2), []rune(s2))

	// INDEX ACCESS; slice of composite data structure
		s[2]  // 3rd element of the slice

		s := []string{}

		// SAFELY check for slice element

		s[0] 	// PANIC : "panic: runtime error: index out of range [0] with length 0"
		len(s) 	// 0

	// INDEX ACCESS :: reset
		s := make([]int, 1)  // [0]
		s[0] = 7             // [7]
		s[0]++               // [8]

	// APPEND per builtin;  https://tour.golang.org/moretypes/15  
	func append(slice []Type, elems ...Type) []Type  // signature of builtin
	// GROWs length AND (doubles) capacity, as necessary 
		// append ELEMENTS
			s = append(s, 2, 3, 4)  
		// append a SLICE to a SLICE (all its elements) 
			x := []int{1,2,3}    // L/C (3/3)  []int{1, 2, 3}
			y := []int{4,5,6}    // L/C (3/3)  []int{4, 5, 6} 

			// ellipsis,`...`, UNPACKs slice `y` and APPENDS all its ELEMENTs
			x = append(x, y...)  // L/C (6/8)  []int{1, 2, 3, 4, 5, 6} 

	// COMPARISON TESTs
	// Unlike arrays, slices are not comparable, so we cannot use `==`.
	// The ONLY viable test for non-byte-type slices:  
		if len(s) == nil { /* ... */ }  
		// testing `s` itself would be bad ... 
			var s []int  // len(s) == 0; s == nil
			s = []int{}  // len(s) == 0; s != nil; ... BAD !!! 

	// `Equal()`; use ONLY if both slices are of `[]byte` TYPE
		// bytes package; test if `a` and `b` slices are SAME LENGTH & contain SAME BYTES
		func Equal(a, b []byte) bool  // signature 

			bytes.Equal(s1, s2)  // `true` or `false`

	// IMPLEMENT a STACK using a SLICE 
		stack = append(stack, val)    // PUSH val  
		top  := stack[len(stack)-1]   // GET val @ TOP of stack (LIFO)
		stack = stack[:len(stack)-1]  // POP val  

	// RANGE over SLICE 
		type user struct {
			name string
			email string
		}
		// VALUE SEMANTICS 
		for i, u := range users {
			fmt.Println(i, u) // u is COPY of `users`
		}

		// POINTER SEMANTICS  
		for i := range users {// All `users[i]` operations are on `users`, itself.
			fmt.Println(i, &users[i]) // ArdenLabs example FAILS TO COMPILE !!!! 
			fmt.Println(i, users[i])  // Okay
		}
		// https://www.ardanlabs.com/blog/2017/06/for-range-semantics.html 

		// POINTERs @ SLICE 
			*s[i]    // FAIL; "...does not support indexing"  ERROR
			(*s)[i]  // good (SOLVE)
			// E.g.,
			for key := range *cfg {
				(*cfg)[key] = os.Getenv(key)
			}

	// SLICE of POINTER to STRUCT
		[]*A
		// Used, e.g., @ RECURSIVE data structures ... 
		type TreeEntry struct {
			Slug     string        
			Level    int          
			Children []*TreeEntry 
		}
		// is 10x FASTER :: Benchmark  https://stackoverflow.com/questions/27622083/slices-of-structs-vs-slices-of-pointers-to-structs 

		// HOW TO ACCESS (dereference)  
			t := TreeEntry{
				Slug:  "root",
				Level: 0,
				//Children: make([]*TreeEntry, 0),
				//Children: []*TreeEntry{},
				Children: []*TreeEntry{{Slug:"about-us", Level: 1},{...},...},
			}

			fmt.Printf("%+v\n", t) 
			// {Id:0 Slug:root Level:0 Children:[0xc00007e840]}
			fmt.Printf("%+v\n", (*t.Children[0]).Slug) 
			// `about-us`
			// All indices; any field ...
			for _, v := range t.Children {
				fmt.Printf("%+v\n", (*v).Slug)
			} // `about-us`

		// `range` vs `i++` @ `[]*T` 
		// https://github.com/golang/go/issues/22791  
			
			// `range` :: Use for READ ONLY of `a` (`v`). 
			// Address is that of the iteration variable `v`; does not change during loop execution; value overwritten at each iteration.  
				var a = []*A 
				for _, v := range a {
					b = append(b, &v) // type must match, so must use pointer 
				}

			// `i++` :: Use if mutating (`a`). 
			// Address is that of array element `a[i]`.
				for i := 0; i < len(a); i++ {
					b = append(b, &a[i])
				}

			// `range` FAILs @ Slice of Pointer to Struct (`[]*A`)
				type A struct {a, b int}
				a := A{{0 1},{1 2},{2 3},{3 4}}
				var b []*A // append per range (FAIL; all IDENTICAL)
				for _, v := range a {
					b = append(b, &v) 
				} // [0xc0000ac0b0 0xc0000ac0b0 0xc0000ac0b0 0xc0000ac0b0]
				for _, v := range b {
					fmt.Println(v, v.a, v.b)
				} // {3 4} 3 4, {3 4} 3 4, {3 4} 3 4, {3 4} 3 4,

			// SOLUTION :: append per `i++` 
				for i := 0; i < 5; i++ {
					x = append(x, &A{a: i, b: i + 1})
				} // [0xc0000ac140 0xc0000ac150 0xc0000ac160 0xc0000ac170]

				// Okay to READ per `range`
				for _, v := range x {
					fmt.Println(*v, v.a, v.b)
				} // {0 1} 0 1, {1 2} 1 2, {2 3} 2 3, {3 4} 3 4,

	// IN-PLACE SLICE TECHNIQUES (sans assignment)

		// REVERSE a slice of integers  
		for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
			s[i], s[j] = s[j], s[i]
		}
		// REVERSE entire array 
		func reverse(s []int) {
			for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
				s[i], s[j] = s[j], s[i]
			}
		}
		reverse(s[:]) 

		// ROTATE a slice left by `n` elements: apply `reverse` 3 times: 
		// 1st to the leading `n` elements, then to the remaining elements, and finally to the whole slice. 
		// (To rotate right, make the third call first.)
			// Rotate left by 2 elements
				reverse(s[:2])
				reverse(s[2:])
				reverse(s)

		// NONEMPTY (2 variants)  https://notes.shichao.io/gopl/ch4/#reversing-and-rotating-slices
		// returns a slice holding only the non-empty strings.
		// The underlying array is modified during the call.
			func nonempty2(strings []string) []string {
				out := strings[:0] // zero-length slice of original
				for _, s := range strings {
					if s != "" {
						out = append(out, s)
					}
				}
				return out
			}

		// REMOVE (DELETE) an element (i) whilst maintaining order of remaining elements; 
		// use copy to slide the higher-numbered elements down by one to fill the gap: 
			func remove(slice []int, i int) []int {
				copy(slice[i:], slice[i+1:])
				return slice[:len(slice)-1]
			}

			// ... from GOPL, ch.4; but is NOT an in-place function. 
			s := []int{5, 6, 7, 8, 9}  // L/C (5/5)  []int{5, 6, 7, 8, 9}
			remove(s, 2)               // L/C (5/5)  []int{5, 6, 8, 9, 9} ... NOT an in-place function
			s = remove(s, 2)           // L/C (4/5)  []int{5, 6, 8, 9}

			fmt.Printf("L/C (%v/%v)  %#v\n", len(s), cap(s), s)  

	// TWO-DIMENSIONAL Arrays and Slices
		// https://golang.org/doc/effective_go.html#two_dimensional_slices
		// Go's arrays and slices are one-dimensional. Multi-dim created by nesting.

		// per make() or var
			records := make([][]string,0)  // `[]`
			// OR
			var records [][]string         // `[]`

			// then add slices per append() or index-access syntax
				records = append(records, r1Slice)  // auto-handle indices
				// OR
				records[0] = r1Slice                // specify the index

		// per TYPE DECLARATION + VAR  DECLARE/INITIALIZE:
		// Type `Transform` is a 2x3 array; an array of integer arrays
			type Transform [2][3]int        // DEFINE the TYPE
			t := Transform{{1,2,3},{5,6,7}} // DECLARE and INITIALIZE; [[1 2 3] [5 6 7]]
		// Type `LinesOfTexst` is a slice of byte slices; both of dynamic length.
			type LinesOfText [][]byte       // DEFINE the TYPE
			text := LinesOfText{            // DECLARE and INITIALIZE; [[78 111 119 32 ...
				[]byte("Now is the time"),  // Note UTF-8 codepoints in bytes; `N`=78, ` `=32
				[]byte("for all good gophers"),
				[]byte("to bring some fun to the party."),
			} //=>  [[78 111 119 32 ...] [102 ... 114 115] [116 ...121 46]]

		// TWO WAYS to ALLOCATE a 2D Slice
		/*
			1. allocate each slice independently; use if slices can grow or shrink
			2. allocate a single array and point the individual slices into it; more efficient
			See Examples @ https://golang.org/doc/effective_go.html#two_dimensional_slices
		*/


// STRUCT  {key1 type1; key2 type2} 
/* 
	An aggregate data TYPE composed of FIELDs defined by NAMEs and TYPEs; has NAMED VALUES; zero or more KEY/VALUE PAIRS, called NAMEs and their FIELD VALUEs respectively, each of any type, all treated as a single entity (an OBJECT). Fields may be of any type, including array, slice, map, and/or other structs (explicitly or implicitly per EMBEDDED FIELDs or ANONYMOUS FIELDs respectively); unlike its constituent fields/types, a (merely) declared struct does NOT have a defined zero-value; NOR do any of its fields, i.e., a struct MUST be BOTH declared AND initialized; capitalized field names are EXPORTABLE; struct may have mix of (non)exportable fields, which is the Golang ENCAPSULATION mechanism. Structs are typically employed as the custom type for receivers (of methods). Methods (functions bound to such a type) implement all the goodness of OOP languages without the rigidity of the latter. 
	https://golang.org/ref/spec#Struct_types  https://talks.golang.org/2015/tricks.slide#7  
*/
	type aStruct struct { // a struct with 4 fields
		Name        string `json:"name,omitempty"`
		ID          int
		Foo         rune
		Enabled     bool
	}
	// created per LITERAL
	d1 := &[]aStruct{{  // d1 is type `*[]main.aStruct`
		Name:    "gopher",
		ID:      123456,
		Enabled: false,
	}, {
		Name:    "doc",
		ID:      8765,
	}}
	fmt.Printf("%+v\n",d1)
	// &[{Name:gopher ID:123456 Foo:0 Enabled:false} {Name:doc ID:8765 Foo:0 Enabled:false}]

	// CREATE per TWO STEP PROCESS

		// 1. TYPE DECLARATION
			type aStruct struct {name string; age int}  // UNESCAPED keys

		// 2. VAR DECLARE & INITIALIZE (3 WAYS)

			// 1. per COMPOSITE LITERAL (STRUCT LITERAL)
				s := aStruct{}                    // sets all fields to zero values per type

				// has 2 forms 
					// 1. BAD; sans names; ALL fields required, and in order
					s := aStruct{"Amy", 44}  // any subsequent reordering of the struct type breaks this assignment.      
					
					// 2. with names; unordered okay; absent fields set to zero-value
					s := aStruct{name:"Amy", age:44} 

				// SLICE of STRUCT; multiple sets of struct data
				s := []aStruct{{                  
					...
					} , {
					...
					}}

			// 2. per `make` + `append`
				s := make([]aStruct,0,100)
				s = append(s,aStruct{name:"Amy", age:44})

				// E.g., 
					type aFoo struct {
						group string
						names []string
					}
				// 1. per `make` + `append`
					sites := make([]aFoo,0,100)
					sites = append(sites,aFoo{"grpFoo", []string{"1", "2"}})
					sites = append(sites,aFoo{"grpBar", []string{"a", "b"}})

				// 2. per literal
					sites := []aFoo{{ 
						"grpFoo", []string{"1", "2"},
					}, {
						"grpBar", []string{"a", "b"},
					}}

				fmt.Printf("%+v\n", sites)  // NICE way to print structs; keys:vals
				// [{group:grpFoo names:[1 2]} {group:grpBar names:[a b]}]

			// 3. DOT NOTATION (by LEAF, if embedded; see below)
				s.name = "Bob"  // set 
				s.age = 44
				s.name          // get 

	// NO LOOP ACCESS; NO range 

	// COMPARING STRUCTs (and FIELDs) 
		type Point struct{ X, Y int }
		p := Point{1, 2}
		q := Point{2, 1}
		fmt.Println(p.X == q.X && p.Y == q.Y) // "false"
		fmt.Println(p == q)                   // "false

	// ANONYMOUS STRUCT per SHORT DECLARATION (STRUCT LITERAL)
	// (named structs have NO short-declaration)
		s := struct {name string; age  int} {"Amy", 44} // ONLY if ANONYMOUS struct
		s := struct{ A, B string }{B: "bar"}      // 1st field IMPLICITly assigned; type + zero value
		s := struct{ A, B string }{"foo", "bar"}  // ALL and ORDERed fields (required), if sans names 

	// EMBEDDED FIELDs; structs containing structs 
		type Point struct{ X, Y int }
		type Circle struct {
			Point         // Embedded (ANONYMOUS); name only; no explicit type
			pt Point      // NOT Embedded
			Radius int
		}
		type Wheel struct {
			Circle      // Embedded (ANONYMOUS)
			Spokes int
		}

		// PROMOTE :: inner type ACCESSed DIRECTLY by OUTER TYPE FIELD; embedded struct, or name or field therein, per LEAVES ...
			w := Wheel{Circle{Point{X
			// Then, refer to name(s) by LEAVES of the IMPLICIT TREE 
				w.X               // embeds allow this abbreviated dot notation
				w.Circle.Point.X  // EQUIVALENT  
		// OVERRIDING by PROMOTION (see METHODs section);
			// On any name collision, the OUTER-TYPE overrides INNER-TYPE  

	// POINTERs TO STRUCTs (structs are VALUE TYPEs; unlike slice, map, and simple types)
		type Vertex struct{ X, Y int }  
		r := Vertex{X: 1, Y: 2}

		// create p, a pointer to r 
			var p *Vertex = &r
			// OR
			p := &r            

		// IMPLICITly DEREFERENCEd, unlike other pointers; directly accessible; 
			p      // &{1 2}  (Note it's a "value", NOT an "address".)
			r      // {1 2}
			*p     // {1 2}

			// same for FIELDs; ACCESS per IMPLICIT dereference
				p.name        // use this notation; field value is DEREFERENCED IMPLICITLY
				(*p).name     // equivalent notation; cumbersome; don't use
				p.name = val  // sets `r.name` to `val` 

	// JSON  https://blog.golang.org/json-and-go  
		//   http://jsoniter.com/go-tips.html  
		// ONLY EXPORTED FIELDs (CAPITALIZED Struct Field Names) are MARSHALLED 
		type jStruct struct {
			MsgToken string    `json:"msgToken"`  // FIELD TAG
			MsgID   string    `json:"msgID"`
			MsgDate  time.Time `json:"msgDate"`
		}
		ss = []jStruct{/* enter the data*/ }  // per slice LITERAL

		// MARSHALING :: ENCODING to JSON, from Struct
			// ONLY CAPitalized fields will marshall. 
			// `json.Marshal` PRODUCEs `[]byte`; SERIALIZEd data.
				data, err := json.Marshal(ss)
				if err != nil {
					log.Fatalf("JSON marshaling failed: %s", err)
				}
				fmt.Printf("%s\n", data)
				
			// `json.MarshalIndent`; make human-readable; pretty print 
				data, err := json.MarshalIndent(ss, "", "    ")
				if err != nil {
					log.Fatalf("JSON marshaling failed: %s", err)
				}
				fmt.Printf("%s\n", data)  

		// UNMARSHALLING :: DECODING from JSON to Struct
			sliceJSON := []struct{ Title string }
			if err := json.Unmarshal(data, &titles); err != nil {
				log.Fatalf("JSON unmarshaling failed: %s", err)
			}
			fmt.Println(titles) // "[{Casablanca} {Cool Hand Luke} {Bullitt}]"

			// @ (Un)Marshalling JSON, use pointers to distinguish UNSET from all else;
			// If the field does NOT EXIST (UNSET), then the pointer is nil.
			// So, REGARDLESS OF TYPE, ONE TEST is all we need: `Struct.Field != nil`.
			// If `true` then field is SET, else UNSET; works regardless of field value.

			// UpdateUser defines the User fields that are modifiable by a client.
			// All fields are optional so clients can send only those to change.
			// Pointer fields are used to differentiate between a field that
			// was not provided and a field that was provided as explicitly blank.
			type UpdateUser struct {
				NameFull        *string  `json:"nameFull"`
				Email           *string  `json:"email"`
				Roles           []string `json:"roles"`
				Password        *string  `json:"password"`
				PasswordConfirm *string  `json:"passwordConfirm" validate:"omitempty,eqfield=Password"`
			}
			var upd data.UpdateUser
			if err := web.Decode(r, &upd); err != nil {
				return errors.Wrap(err, "")
			}
			// REF: https://github.com/ardanlabs/service/blob/master/internal/platform/web/request.go 
		
		// CONVERSION :: if you have a CONCRETE TYPE, use conversion
			string(obj)
			float64(obj)

		// CASTING :: if you have an INTERFACE, use the cast
			obj.(float64)

// MAPs  map[key2:val2 key3:val3 key1:val1 ...]  type map[K]V
/*
	HASH TABLE; key/value pairs; each key is UNIQUE; all KEYS are ONE TYPE, `K`; all VALUES are ONE TYPE, `V`; key types and value types may differ; map TYPE is `map[K]V`; itself a REFERENCE TYPE, like pointers and slices; map keys can be of any type for which the equality operator is defined, e.g., int, float, complex, strings, pointers, interfaces, structs and arrays. SLICES CANNOT BE USED AS MAP KEYS since equality is not defined on them.  
	https://golang.org/doc/effective_go.html#maps
*/ 
	// TYPE 
		map[K]V  // where K, V are TYPEs

	// CREATE (TWO WAYS)
	// 1. per `make()`; allocates & inits hash map data structure; 
	//    returns map value pointing to it.
		aMap = make(map[string]int)
			// CAPACITY HINT (optional); does NOT set|limit size
				aMap = make(map[string]int, 21)
				fmt.Println(len(aMap))  //=> 0
		// then insert/update per KEY ACCESS
			aMap["foo"] = 22
		// SHORT DECLARATION
			aMap := make(map[string]int)

	// 2. per MAP LITERAL (COMPOSITE LITERAL) syntax; 'shorthand'
	// I.e., a MAP of a STRUCT; note the PARTICULAR SUBSET OF POSSIBLE STRUCTS: 
	// structs of which all elements are the SAME `K/V` TYPE
		aMap := map[string]int{}
		aMap := map[string]int{"foo":1, "bar":2}  //=> map[foo:1 bar:2]

		// okay to OMIT the STRUCT's top-level TYPE-name [per element]
		var aMap = map[string][]int{   // ...SHORTHAND for ... 
			"key2": {56},              //  "key2": []int{56}, 
			"key3": {22,-44,33},       //  "key3": []int{22,-44,33}, 
			"key1": {99},              //  "key1": []int{99},
		} 
		// map[key2:[56] key3:[22 -44 33] key1:[99]]

			// DO NOT create a map thus; creates a USELESS `nil` map
				// BAD !!!
				var aMap map[string]string     //=> zero-value is `nil`
				fmt.Println(aMap == nil)       //=> true
				aMap["foo"] = "bar"            //=> "panic: assignment to entry in nil map"

	// CUSTOM TYPE MAP
		type Months map[string]int             // Note: different from "BAD!!!" way
		m := Months {
			"January":31,
			"February":28,
		}
		fmt.Println(m["March"])                // `0`, i.e., SAFE 

	// ACCESS / INSERT or UPDATE an element
		aMap[key] = value  // always safe; `[]` @ key not exist; 
		                     // IF created per `make`, else `panic`
	// RETRIEVE an element:
		value = aMap[key]  // always safe; type's zero-value if not exist
		                     // IF created per `make`, else `panic`
	// DELETE an ELEMENT per builtin:
		delete(aMap, key)  // always safe; no-op if not exist
		                     // IF created per `make`, else `panic`

	// ITERATE / LOOP / RANGE over a map; TWO-VALUE assignment
		for key, val := range aMap {...}  // sequence/ORDER VARIES per execution (by design)
	// ITERATE / LOOP / RANGE over a map; ONE-VALUE assignment (is okay too)
		for key := range aMap {...}          // used @ channels  
		// E.g, 
			type client chan<- string        // an outgoing message channel
			messages = make(chan string)     // all incoming client messages
			clients := make(map[client]bool) // all connected clients
			msg := <-messages
			// keys of `clients` (`client` channels) are all set to `msg` (string)
			for cli := range clients {
				cli <- msg  
			}

		// E.g., 
			b := make(map[string][]byte,2)
			// create MAP LITERAL to RANGE OVER STRUCT values (to convert its strings to byte slices)
			for k, v := range map[string]string{"username": site.User, "password": site.Pass} {
				b[k] = []byte(v)
			} //  https://play.golang.org/p/n5ql273S2w9

		// SORTing (Go maps don't sort, so convert its keys to a SLICE, and sort that.)
		// ORDERED  https://notes.shichao.io/gopl/ch4/#map-iteration
			import "sort"                                 // `sort.Strings()`
			keys := make([]string, 0, len(aMap))          // PREALLOCATE empty slice; for efficiency
			for key, _ := range aMap {                    // fill the `keys` slice with `aMap` keys
				keys = append(keys, key)
			}
			sort.Strings(keys)                            // sort the `keys` slice (keys of `aMap`)
			for _, key := range keys {                    
				fmt.Printf("%s: %d\n", key, aMap[key])    // print map sorted per keys slice
			}

	// TEST if KEY EXIST; a TWO-VALUE ASSIGNMENT
	// always safe; `0` if non-existent key
		if val, ok := aMap[key]; ok {...}  
		// If `key` exist, then `ok` is `true`, else `false`.
		// If `key` NOT exist, then `val` is ZERO-VALUE per its element type, `V`.

	// COMPARISON of maps 
	// test whether two maps contain the same keys and the same associated values
		func equal(x, y map[string]int) bool {
			if len(x) != len(y) {  // false if unequal lengths
				return false
			}
			// true only if key and value exist & same, for every key
			for k, xv := range x {  
				if yv, ok := y[k]; !ok || yv != xv {
				return false
				}
			}
			return true
		}  

	// HASH TABLEs / HASH BUCKETS / Readers / Scanners / Get
		// https://github.com/GoesToEleven/GolangTraining/tree/master/19_map/14_hash-table

	// SET DATA STRUCTURE 
		// Golang has NO explicit set data structure, so SETs are IMITATED per MAPs 
		// https://notes.shichao.io/gopl/ch6/#example-bit-vector-type 
			set := make(map[T]bool)  // where T is the element type

		// very flexible, but a specialized representation may outperform it. 
		/*  
			A BIT VECTOR is ideal in the following example cases:
			  - Dataflow analysis where set elements are SMALL NON-NEGATIVE INTEGERS.
			  - Sets have MANY ELEMENTS.
			  - Set OPerations like UNION and INTERSECTION are COMMON.
	
			A bit vector uses A SLICE OF UNSIGNED INTEGER VALUES or "words", each bit of which represents a possible element of the set. The set CONTAINS `i` IF the `i-th` BIT IS SET. 
		*/

// POINTERs
	p = &r
/* 
	A pointer is a variable whose VALUE is a memory ADDRESS; NO POINTER ARITHMETIC, unlike C.
	POINTERs have TYPEs; if `p` points to a variable typed `T`, then `p` is of type `*T`
	The `&` operator is valid for ANY addressable obj/var, not merely for pointers.
*/
	&  // ADDRESS-OF OPERATOR; GENERATEs a pointer (variable) whose value is the ADDRESS of OPERAND 

	*  // INDIRECTION OPERATOR; DEREFERENCEs a pointer; denotes the UNDERLYING VALUE; 
	   // denotes the VALUE at the address which is the value of the operand (pointer variable).

	r := 2
	p := &r     // short declaration okay for pointers, IF @ func
	// OR
	var p *int  // can NOT initialize here; can skip this per SHORT DECLARATION, `p := &r`
	p           // `<nil>` until assigned; attempting to dereference would cause panic.
	p = &r      // address of `r`, e.g., 0xc04200e130; point to `r`; `p` has type `*int`
	p           // address of `r`, e.g., 0xc04200e130; point to `r`; `p` has type `*int`
	*p          // value of `r`; value at address of `r`; value at address at value of `p`; dereference 

	/* 
	Passing to functions, per type; since Golang always passes by value, for function|method to affect the var passed, must use pointers on VALUE-TYPES, but not on REFERENCE-TYPES.

		VALUE-TYPES        REFERENCE-TYPES 
		-----------        ---------------
			int                slice 
			float              map 
			string             channel 
			bool               pointer 
			struct             function   ... note that STRUCT is the only complex value type
	*/

	// DEREFERENCING or INDIRECTING
		fmt.Println(*p) // read `r` through the pointer `p`
		*p = 21         // set `r` through the pointer `p`

	// Pointer EXAMPLE
		var p *int            // DECLARE pointer
		fmt.Println(" p", p)  // nil
		fmt.Println("*p", *p) // panic; nil pointer dereference
		// ... try again ...
		r := 42
		var p *int            // DECLARE pointer
		p = &r                // SET/INITIALIZE pointer
		// OR
		p := &r               // declare and initialize

		fmt.Println(" r", r)  // 42; value of `r
		fmt.Println(" p", p)  // 0xc04204c080; VALUE of pointer `p` is ADDRESS of `r`
		fmt.Println("&r", &r) // 0xc04204c080; address of `r`
		fmt.Println("*p", *p) // 42; get value of r through pointer `p`
	
		*p = 21               // RESET `r` through pointer `p`
	
		fmt.Println(" r", r)  // 21; VALUE of `r` CHANGED
		fmt.Println(" p", p)  // 0xc04204c080; UNCHANGED; VALUE of pointer `p` is ADDRESS of `r`
		fmt.Println("&r", &r) // 0xc04204c080; UNCHANGED; address of `r`
		fmt.Println("*p", *p) // 21; get value of `r` through pointer `p`

	// Pointer syntax @ function def/use/call
		func foo(p *T) {.. *p ...}  // @ def, `*` operator @ type ONLY, unlike use of the param therein.
		foo(&r)  // arg `r` is type `T`

	// Pointer syntax @ ITERATION 
		(*p)[index]

	// Returning a pointer; like a closure; PERSISTs; each call returns unique instance [address/value] 
		var p = f()

		func f(a int) *int {
			v := 1 + a
			return &v
		}
	
// ALLOCATION [of memory] [builtins]
	// Golang handles stack/heap allocation

	// MAKE   https://golang.org/search?q=make#Global_pkg/builtin
		make()  // creates only SLICES, MAPS, and CHANNELS; returns INITIALIZED object, type T (not *T)
		func make(t Type, size ...IntegerType) Type  // signature of builtin
		// make CHANNEL
		c := make(chan int)  // c has type `chan int`; `size` is BUFFER size 
		// UNBUFFERed if size is ommitted

		// make SLICE
		make([]type, len, cap)  // allocates a zeroed (underlying) array of `type`, of size `cap`, 
		// and then returns a slice thereof, size `len` and capacity `cap`, which points to the 
		// first `len` elements of the array; `cap` is optional, defaulting to `len`.
		// e.g., 
			b := make([]int, 3, 5)  // b=[0 0 0],     len(b)=1, cap(b)=5
			b[1] = 999              // b=[0 999 0],   len(b)=3, cap(b)=5
			b = b[1:cap(b)]         // b=[999 0 0 0], len(b)=4, cap(b)=4
			b[3] = 7                // b=[999 0 0 7], len(b)=4, cap(b)=4
			b = b[:2]               // b=[999 0],     len(b)=2, cap(b)=4  

	// NEW 
		new(T) // [RARELY USED] returns a POINTER to a newly allocated zero-value of type `*T`
		func new(Type) *Type           // signature of builtin
		// e.g., 
			p := new(chan int)   // p has type `*chan int` 

// CUSTOM TYPEs
	type age int
	type money float32
	type months map[string]int
	m := months {
			"January":31,
			"February":28,
			...
	}
// FLOW CONTROL 

	// LOOP construct 
		for init-stmt; condition-expr; post-stmt {/* loop */} 
		// e.g., 
			for i := 0; i < 10; i++ {/* loop */}     // `i` SCOPEd to loop 
		// init & post statements are OPTIONAL 
		for init-stmt; condition-expr; {/* loop */}  // NOTE trailing `;` REQUIRED there 
		for condition-exp {/* loop */}               // NOTE trailing `;` FORBIDDEN there 
		// condition-exp is OPTIONAL  
		for {/* loop */}  // i.e., infinite loop; yet `break`, `continue` available

		// RANGE CLAUSE
			// NO range over STRUCT.
			// iterate over ARRAY, SLICE, STRING, MAP, or READING from a CHANNEL
			// If over a CHANNEL, it loops (reads) until channel is CLOSED.
			// Ranging returns two values (per iteration); INDEX (KEY) and its VALUE (a copy)
			for key, value := range oldMap {
				newMap[key] = value
				counter++  // syntax; to increment some counter, for some other reason
			}
			// If only FIRST ITEM needed …
				for key := range m {
					if key.expired() {
						delete(m, key)
					}
				}

		// BLANK IDENTIFIER; `_`  https://golang.org/doc/effective_go.html#blank
			// to skip over one param (key OR value)
			sum := 0
			for _, value := range array {
					sum += value
			}

		// when applied to a string, range DECODEs UTF-8 implicitly.
			for i, r := range "Hello, 世界" {
				fmt.Printf("%d\t%q\t%d\n", i, r, r)  
				// @ eighth loop, prints: "7	'世'	19990"
			}

		// ISSUE :: LOOP VARIABLE CAPTURE 
			// See "CLOSUREs with GOROUTINEs" section

	// CONDITIONAL construct
		// vars therein are SCOPED TO it; to `{...}`

		// IF
			if expr {/* body */}  // conditional expression; can act like a `for` loop
				// E.g., 
				 	if x != y  {/* body */}
			
			if short-stmt; expr {/* body */}  // can prepend a short-statement
				// E.g., 
					if x := 2; x < y {/* body */}  // NOTE `x` is SCOPEd to `if` 
					if x, good := aMap[2]; good {/* body */}  // see MAP secion

		// IF/ELSE
			var lim int = 10
			if v := math.Pow(x, n); v < lim {
				return v
			} else {
				fmt.Printf("%g >= %g\n", v, lim)
			}
			return lim  // can't use v here, though

		// Note SCOPE issues handled
		// var def prior, AND `=` NOT `:=` inside conditional block
		var err error  
		if flag = "yes" {
			out, err = aFuncReturning2Values()
		}
		if err != nil { fmt.Errorf("BAD :: %v\n", err) }

		// SWITCH/CASE
			// a shorter way to write a SEQUENCE OF if/else STATEMENTS.
			// It runs the first case whose value is equal to the condition expression.
			// breaks are automatic; cases needn't be constants; values needn't be integers
			switch init;condition {…}  // switch per condition, with init
			switch condition {…}       // switch per condition
			switch {…}                 // switch TRUE

			switch os := runtime.GOOS; os {
			case "darwin":
				fmt.Println("OS X.")
			case "linux":
				fmt.Println("Linux.")
			default:
				fmt.Printf("%s.", os)
			}

			today := time.Now().Weekday()
			switch time.Saturday {
			case today + 0:
				fmt.Println("Today.")
				…
			}
		
		// SELECT (switch for channels)
			// See CONCURRENCY section

// FUNCTIONs  
/*
	2 types of VISIBILITY: only Exported (capitalized) vs. Unexported (Not capitalized); 
	NO CLASSES (public/private/…); RECURSION tends to be safe; Golang avoids overflow 
	by using VARIABLE-SIZE STACKS  
	https://notes.shichao.io/gopl/ch5/#function-declarations 
*/ 
	func funcName(par1 type, par2 type, …) {/* body */}  // sans return
	func funcName(par1 type, par2 type, …) rtn1Type {/* body */} // return
	func funcName(par1 type, par2 type, …) (rtn1Type, rtn2Type,...) {/* body */} // (multiple) return(s)
	func funcName(par1 type, par2 type, …) (namedRtn1 type, namedRtn2 type, …) {/* body */}  // named return(s)
	// BARE RETURN (NAKED RETURN), `return` sans var-name(s), okay @ funcs having NAMED returns
	func funcName(par1 type, par2 type, …) rtn1Type // sans body; @ pkg written in OTHER LANGUAGE

	// FUNCTION TYPE (SIGNATURE)
		func add(x, y int) int { return x + y }  // is TYPE ...
		func(int, int) int  // a.k.a. (type) SIGNATURE 

	// MAIN execution entry point
		func main() {/* body */}  // `main` function is special; the execution entry point.

	// PASSING BY VALUE; In Go, EVERYTHING is PASSED BY VALUE, always; HOWEVER, all complex types except struct (map,slice,function,pointer) are REFERENCE TYPEs, so pointers are not needed (to persist their mutation by function).
		
	// PASSING POINTERs (PASSING BY REFERENCE; per type `*T`)  
		func foo(param *T) {...; *param = ...;}  // syntax @ pointer PARAM; type is pointer; `*T`
		foo(&arg)                                // syntax @ pointer ARG; `&arg` [is type `T`]

	// If VARIADIC PARAM, then compiles the var into a SLICE
		// call ...
		learnVariadicParams("learning", 44, "things!")

		func learnVariadicParams(myStrings ...interface{}) { 
			// string args turned into a slice
			for _, param := range myStrings {
				fmt.Println("param:", param)
			}
			/* 
				param: learning
				param: 44
				param: things!
			*/
			// Pass variadic value as a variadic parameter.
			// If VARIADIC ARG, then compiles var into CSV
			fmt.Println("params:", fmt.Sprintln(myStrings...))
			fmt.Println("params:", "learning", 44, "things!")
			/* 
				params: learning 44 things!
				params: learning 44 things!
			*/
		}

	// if SLICE PARAM
		data := []float64{43, 56, 87, 12}
		// handle per VARIADIC ARG
			func foo(vary ...float64) {/* body */}  // `vary` is a SLICE; scoped to `foo`
			foo(data...)                            // length of slice varies
		// handle per SLICE ARG
			func foo(vary []float64) {/* body */}   // `vary` is a SLICE; scoped to `foo`
			foo(data)                               // length of slice varies

		A := []string{"foo", "bar"}
		doVariadic(A...)      // slice arg passed as csv (string) args, and received as slice param
		doVariadic("foo,bar") // string arg received as slice param
		func doVariadic(s ...string) {
			fmt.Println(s) // [foo bar]
		}

	// FUNCTION VALUES
		// A function PASSED as ARGUMENT and/or RETURNED AS A VALUE;
		// its RETURN STATE PERSISTs, i.e., all var values therein are saved.
		// Note `funcName` param defined per function SIGNATURE (its own param/rtn TYPE(s))
		func foo(funcName func(float64, float64) float64) float64 {
			return funcName(3, 4)
		}

		// CALLBACKs
			// `visit` takes a func as an arg; `callback` arg is type `func(int)`
			func visit(numbers []int, callback func(int)) {
				for _, n := range numbers {
					callback(n)
				}
			}
			func main() { 
				// pass (anonymous) function as an arg, to `visit` function
				visit([]int{1, 2, 3, 4}, func(n int) {
					fmt.Println(n)
				})
			}

		// POINTERs :: Return a pointer 
		func foo() *aStruct {
			x := aStruct{}
			// ...
			return &x
		}

	// FUNCTION LITERALs aka FUNCTION EXPRESSIONs aka ANONYMOUS FUNCTIONs
	/*
		Common @ goroutines; executed upon declaration.

		Whereas named functions can be declared only at the package level, NOT @ `main()`, function literals can be nested (within a function); they denote a function VALUE, and are written as an expression; defining the function at its point of use. That is, they are both function definition AND function STATE.

		They maintain ACCESS TO THE LEXICAL SCOPE they are defined in - all the variables available at declaration are also available in the body of the function; like a for-loop body, but each iteration starts a new goroutine (current process).
	*/
		// FUNCTION LITERALs/EXPRESSIONs are CLOSURES.
		// E.g., 
			xBig := func() bool {
				return x > 10000 
			}
			x = 99999
			fmt.Println("xBig:", xBig()) // true
			x = 1.3e3                    // 1300
			fmt.Println("xBig:", xBig()) // false

		// May be defined and called INLINE;
		// IIFEs embed in outer func AND pass as arg to another func.
		// Have ACCESS to (lexical scope) variables of "parent".
		// E.g.,
			func outer() string {
				x := 9
				y := 3
				z := 11 // IIFEs have access to `z`
				func() { fmt.Println(z) }()
				return fmt.Sprintf("DoppleSummer: %v",
					func(a, b int) int { // IIFE passed as arg to `Sprintf()`
						return (a + b + z) * 2
					}(x, y))
			} // 11\nDoppleSummer: 46

		// E.g., 
			go func() {
				results[url] = wc(url)
			}()

		// E.g, 
			strings.Map(func(r rune) rune { return r + 1 }, "HAL-9000")

		// E.g., define a Function Expression (example invokes recursively) ... 
			var visitAll func(items []string) // SCOPEd to `visitAll`, so can call itself 
			visitAll = func(items []string) {...visitAll(m[item]) ...}
			// ... then call it ...
			visitAll(keys)

		// Allows nesting, e.g.,
			func main { // Function Expression
				fooFunc := barFunc() {/* barFunc-body */}
			}
			// E.g.   return: (function string)
			func makeGreeter() func() string {
				return func() string {  // Function Literal
					return "Hello world!"
				}
			} // called @ main ...
			func main() {
				// greet := makeGreeter()
				// fmt.Println(greet())
				// fmt.Printf("%T\n", greet)  // `func() string`
				fmt.Println(makeGreeter()())
			}

		// CLOSUREs
		// returned STATE [values] PERSISTs (per call)
			// E.g., `adder` function returns a closure.
			// Each closure is bound to its own sum variable
			func adder() func(int) int {
				sum := 0
				return func(x int) int {
					sum += x
					return sum
				}
			}
			func main() {
				A := adder()
				B := adder()
				fmt.Println("A:", A(5), A(2))   // A: 5 7
				fmt.Println("B:", B(9), B(-3))  // B: 9 6
			}

			// E.g., fibonacci; returns next in sequence with each call;
			//   values of `f` and `g` persist; not due to closure,
			//   but because function RETURNED AS A VALUE.
			func fibonacci() func() int {
				f, g := 1, 0
				return func() int {
					f, g = g, f+g  // values PERSIST because FUNCTION is RETURNED AS A VALUE
					return f
				}
			}
			// called ...
			f := fibonacci()
			for i := 0; i < 10; i++ {
				fmt.Println(f())  // 0 1 1 2 3 5 8 ...
			}

	// DEFER
		// defers function execution UNTIL SURROUNDING FUNCTION RETURNS.
		func main() {
			defer fmt.Println("world")
			defer fmt.Println("... pause ... (Defers execute per LIFO.)")

			fmt.Println("hello")
		}
		// it PUSHES function calls ONTO a STACK.
			for i := 0; i < 10; i++ {
				defer fmt.Println(i)   // => 9, 8, 7, …
			}

	// NAMED RETURNs; per vars defined at top of func; AVOID using unless ambiguous otherwise
		func split(x int) (foo, bar int) {
			...
			return  // NAKED or BARE return; RETURNS the NAMED RETURN VALUES
		}
		// but useful with DEFER
		// https://www.goinggo.net/2013/10/functions-and-naked-returns-in-go.html
			func ReturnId() (id int, err error) {
				defer func(id int) {
						if id == 10 {
							err = fmt.Errorf("Invalid Id\n")
						}
				}(id)

				id = 10

				return
			}

	// INIT FUNCTION 
		// Can't be called or referenced; otherwise, are normal functions that automatically execute, prior to `main()`, in the order in which they are declared; used to verify or repair correctness of the PROGRAM STATE BEFORE REAL EXECUTION BEGINS.  https://golang.org/doc/effective_go.html#init
		func init() {/* body */} 
			
		// E.g., Process template prior to launching server @ `main()` 
			func init() {
				tpl = template.Must(template.ParseFiles("index.gohtml"))
			}

		//  E.g., set Env. Vars
			func init() {
				if user == "" 
					log.Fatal("$USER not set")
				}
				if home == "" {
					home = "/home/" + user
				}
				if gopath == "" {
					gopath = home + "/go"
				}
				// gopath may be overridden by `--gopath` flag on command line.
				flag.StringVar(&gopath, "gopath", gopath, "override default GOPATH")
			}

	// CONSTRUCTORs
		// utilize COMPOSITE LITERALs to simplify
		func NewFile(fd int, name string) *File {
			if fd < 0 {
				return nil
			}
			f := File{fd, name, nil, 0}  // COMPOSITE LITERAL for type `File`
			return &f 
		}
		// Alternately, per `NAME:VALUE` pairs
			return &File{fd: fd, name: name}
		// allows absent fields; they retain their ZERO VALUE [per type].
		// Note these two are EQUIVALENT (See ALLOCATION)
			new(File) ; &File{}  // (use one, NOT both)

// METHODs
/* 
	A FUNCTION ASSOCIATED WITH A PARTICULAR TYPE; an object is a value or variable that has methods; A method is declared with a VARIANT of the ordinary FUNCTION DECLARATION in which an EXTRA PARAMETER, called the method's RECEIVER, appears BEFORE the FUNCTION NAME; attaches the function to the TYPE of that parameter; "receiver" is a legacy term from OOP, whereof calling a method was "sending a message to an object"; receiver in OOP has special name "this" or "self", but not in Go; Go convention is to name receiver by first-letter of its type name; methods can be associated with any type; STRUCT TYPE RECEIVERS are COMMON; the methods-on-structs duo implements SUBSTITUTABILITY and ENCAPSULATION, which is the goodness of OOP (sans OOP rigidity).   https://notes.shichao.io/gopl/ch6/#chapter-6-methods  
*/
	// METHOD NOTATION 
		v.Method()     // is Go syntactic sugar; receiver `v` is just another param ...
		(T).Method(v)  // long version; receiver param prepends to those (if any) of `Method(params)`

	// METHOD DECLARATIONs  https://notes.shichao.io/gopl/ch6/#method-declarations 
		type Point struct{ X, Y float64 }

		// traditional function; `p`, `q` params of `Point` TYPE
			func Distance(p, q Point) float64 {
				return math.Hypot(q.X-p.X, q.Y-p.Y)
			}
			Distance(p, q)  // FUNCTION CALL

		// same thing per METHOD of `q` on `Point` TYPE `p`
			func (p Point) Distance(q Point) float64 {  
				return math.Hypot(q.X-p.X, q.Y-p.Y)
			}  
			p.Distance(q)   // METHOD CALL

			// NO CONFLICT if BOTH method and its ordinary func are DECLARED in SAME PACKAGE.
			Distance        // NAME of ordinary function 
			Point.Distance  // NAME of function-method, but "method name" is "Distance"
			(p Point)       // NAME of Receiver 

			// The extra parameter `p` is called the method's receiver, a legacy from OO languages whereof "calling" a method was described as "sending a message to an object". Unlike OO, calling message on self, receiver has no special name; `this` or `self`. Golang convention is to name receiver by first letter of its type.

			// ANY VAR (receiver `p` here) of TYPE `Point` has access to `Distance` METHOD.  
			// This is Golang's implementation of class, sans superglued OOP-hell.

		// Multiple methods of SAME NAME, `Distance`, but DIFFERENT TYPE receiver;
		// Note `Path.Distance` uses `Point.Distance`
			type Path []Point
			func (p Path) Distance() float64 {
				sum := 0.0
				for i := range p {
					if i > 0 {
						sum += p[i-1].Distance(p[i])
					}
				}
				return sum
			}

	// Composing Types by STRUCT EMBEDDING
	// allows complex types with many methods to be built up by the composition of several fields, each providing a few methods.  https://notes.shichao.io/gopl/ch6/#composing-types-by-struct-embedding 
		
		// E.g., `ColoredPoint` could be defined as a struct of three fields, but instead embedded a `Point` to provide the `X` and `Y` fields; SYNTACTIC SHORTCUT; contains all the fields of `Point`, plus some more. 
			type Point struct{ X, Y float64 }

			type ColoredPoint struct {
				Point
				Color color.RGBA
			}

		// OVERRIDING per PROMOTION 
			// E.g., access embedded struct, or field therein, per LEAVES ...
			w := Wheel{Circle{Point{X 
			// Then, refer to them by LEAVES of the IMPLICIT TREE 
			w.X               // embeds allow this abbreviated dot notation
			w.Circle.Point.X  // EQUIVALENT  
			
			// E.g., to CHANGE ONE FIELD of ...
			claims := auth.Claims{
				StandardClaims: jwt.StandardClaims{
					Issuer:    "service project",
					Subject:   payerID,  
					Audience:  "app",
					ExpiresAt: now.Add(time.Hour).Unix(),
					IssuedAt:  now.Unix(),
				},
				Roles: []string{auth.RoleUser},
			}
			}
			// per ...
			claims.Subject = payeeID 

			// The fields of `ColoredPoint` contributed by the EMBEDDED `Point` are SELECTABLE with OR without mentioning `Point`; FIELDs of `Point` (inner-type) are PROMOTED to `ColoredPoint` (outer-type); note in this case no outer-type field overrides any (promoted) inner-type field.
				var cp ColoredPoint
				cp.X = 2    // OR `cp.Point.X = 2`
				cp.X        // "2"; referenced per LEAF
				cp.Point.X  // "2"; same object; unnecessarily verbose reference

			// METHODs of `Point` are PROMOTED to `ColoredPoint`
				func (p ColoredPoint) Distance(q Point) float64 {
					return p.Point.Distance(q)
				}

			// I.e., FIELDS and METHODS of the INNER-TYPE are PROMOTED to the OUTER-TYPE
				type person struct {...}
				type doubleZero struct {person ...}
				p2 := doubleZero{    // outer-type
					person: person{  // inner-type
						First: "Miss",
						Last:  "MoneyPenny",
						Age:   19,
					},
					First:         "If looks could kill",  // OVERRIDEs inner-type FIELD
					LicenseToKill: false,
				}
				p2.First         // "If looks could kill";  OUTER-TYPE; OVERRIDES INNER-TYPE
				p2.person.First  // Miss;                   INNER-TYPE 

	// METHOD VALUEs  (an UNCALLED METHOD select)
	/*
		Typically one expression, e.g., `p.Distance()`, a method select and a method call are two distinct expressions; the selector `p.Distance` yields a METHOD VALUE; a function that binds a method (Point.Distance) to a specific receiver value p. This function can then be INVOKED WITHOUT A RECEIVER VALUE; it needs only the non-receiver arguments; useful when a package's API requires a function value and the clients' desired behavior for that function is to call a method on a specific receiver.  https://notes.shichao.io/gopl/ch6/#method-values 
	*/
		p := Point{1, 2}
		q := Point{4, 6}
		distanceFromP := p.Distance    // METHOD VALUE
		fmt.Println(distanceFromP(q))  // "5" 

	// METHOD EXPRESSIONs 

		type T struct {}
		func (T) Foo(s string) { println(s) }

		var fn func(T, string) = T.Foo

	/*
		Related to the method value is the method expression. When calling a method, as opposed to an ordinary function, we must supply the receiver in a special way using the selector syntax. A METHOD EXPRESSION, written T.f or (*T).f where T is a TYPE, e.g., `Point.Distance`, yields a FUNCTION VALUE with a regular first parameter taking the place of the receiver, so it can be CALLED IN THE USUAL WAY. 

		Method expressions can be helpful when you need a value to represent a choice among several methods belonging to the same type so that you can call the chosen method with many different receivers.  https://notes.shichao.io/gopl/ch6/#method-expression 
	*/
		p := Point{1, 2}
		q := Point{4, 6}
		distance := Point.Distance   // METHOD EXPRESSION
		fmt.Println(distance(p, q))  // "5"

	// Example: Bit Vector Type
	/*
		SETs in Golang are usually implemented as a MAP, `map[T]bool`, where `T` is the ELEMENT type; very flexible, but a specialized representation, a BIT VECTOR, may outperform it in certain use cases; a bit vector uses a SLICE OF UNSIGNED INTEGER VALUES or "words", each bit of which represents a possible element of the set. The set contains `i` if the `i-th` bit is set.    https://notes.shichao.io/gopl/ch6/#example-bit-vector-type
	*/

	// VALUE vs POINTER RECEIVERs
		a.methodName(arg1, arg2,…)  // METHOD CALL
		// VALUE RECIEVERs; safe for concurrent access
		func (a aType) methodName(arg1 type, arg2 type, …) (namedRtn1 type, namedRtn2 type, …) {/* body */}
		// POINTER RECEIVERs; 
		// NOT SAFE for concurrent access, YET MORE COMMON than value recievers.
		// MODIFY the receiver IN PLACE (sans return)
		func (a *aType) methodName(arg1 type, arg2 type, …) (namedRtn1 type, namedRtn2 type, …) {/* body */} 
		(*aType).methodName  // The pointer-method NAME is `methodName`
		// https://golang.org/doc/faq#methods_on_values_or_pointers

			//  Golang PASSes BY VALUE, just like regular functions, 
			// so a method of signature ...
			func (t T)MyMethod(s string) {/* body */}  
			// ... is a function of TYPE func(T, string); 

	// POINTER INDIRECTION
	/*
		- Functions with pointer args accept only pointers.
		- Functions with value   args accept only values.

		- Methods with pointer RECEIVERs ACCEPT EITHER. 
		- Methods with value   RECEIVERs ACCEPT EITHER.  

		So, METHOD CALLS NEEDN'T USE POINTER SYNTAX; 
		// go compiler interperets as apropos.

		- Two USES for POINTER RECEIVER:
				1. to modify the value its receiver points to (sans return).
				2. to avoid copying the value on each method call; memory efficiency.

		- ALL the METHODs on a type SHOULD accept EITHER value OR pointer recievers; not a mix of the two.
	*/

	// ENCAPSULATION 
	/*
		An object variable/method is encapsulated if it is INACCESSIBLE to clients of the object; information hiding; a key aspect of OOP; Golang has ONLY ONE MECHANISM to control the VISIBILITY of names: CAPITALIZED identifiers ARE EXPORTED from the package in which they are defined, and UNCAPITALIZED names ARE NOT. This mechanism not only limits access to members of a package, but also limits access to the fields of a struct or the methods of a type. As a consequence, TO ENCAPSULATE AN OBJECT, IT MUST BE MADE INTO A STRUCT. Thus, Golang encapsulates per PACKAGE level, NOT per type, unlike OOP languages.  
	*/  // E.g., 
		type IntSet struct {  // Outside this package, only `*s.words` is accessible, NOT `s.words`
			words []uint64    // private; available ONLY in pkg defining `IntSet`
		}
		// vs. 
		type IntSet []uint64  // UNPROTECTED; value is directly modifiable at any other package.

// ERRORs  
/*
	Golang programs express ERROR STATE with TYPE `error` VALUEs from an ERROR METHOD; 
	Errors are handled using normal FLOW CONTROL on ordinary VALUEs, not per "exceptions".
	This requires more effort, but delivers runtime error reporting far superior to stack trace dumps.  

		https://golang.org/ref/spec#Errors  
		https://tour.golang.org/methods/19
		https://github.com/golang/go/wiki/Errors  
	
	Unhandled errors cause program termination; `panic`, e.g., 
		"panic: runtime error: invalid memory address or nil pointer dereference"
		"[signal SIGSEGV: segmentation violation code=0xffffffff addr=0x0 pc=0x23d68a]"
/*
	An important part of a package's API or an applications' user interface; failure is just one of several expected behaviors. This is the approach Golang takes to error handling.

	A function for which failure is an expected behavior returns an additional result, conventionally the last one. If the failure has only one possible cause, the result is a boolean, usually called `ok`:
*/
	// ERROR TYPE; a builtin INTERFACE:
	type error interface {  // Similar to `fmt.Stringer`, "fmt" pkg
		Error() string      // also looks for this [error] interface
	}  // https://github.com/GoesToEleven/GolangTraining/blob/master/21_interfaces/01_interface/05_io-copy/
	// Functions may return an error value;
	// calling code handles errors by testing if error equals `nil`.

	// Two ways to shutdown an app
		panic()
		os.Exit()

	// convert type `error` to type `string` 
		err.Error() 

		// fmt vs. log vs. panic()
		fmt.Println("FAILed @ ", err.Error())  // FAILed @  ...                     (writes to STDOUT)
		log.Println("FAILed @ ", err.Error())  // 2009/11/10 23:00:00 FAILed @ ...  (writes to STDERR)
		panic(err.Error())                     // panic: err ... (more lines tracing the cause)

		// 3 IDENTICAL (looking) error messages ...
		fmt.Printf("FAILed @ %v", err.Error())                 // 1; format & print to STDOUT

		fmt.Fprintf(os.Stderr, "FAILed @ %v\n", err.Error())   // 2; format & print to STDERR per io.Writer

		e := fmt.Errorf("FAILed @ %v", err.Error())            // 3; format & print to STDERR-string VAR
		fmt.Println(e)                                         // 3; print string var to STDOUT

	// `log.Fatal`, `log.Fatalf`, ... funcs call `os.Exit(1)` after writing log message to STDERR
		log.Fatal(err.Error())    // 2009/11/10 23:00:00 (err message) 
	
	// ERROR PATTERNs

		rtn, err := aFunc()
		if err != nil { // `nil` on SUCCESS, else FAILURE  
			log.Fatalf("The aFunc call bombed cuz: %s", err.Error())  
		}

		// Rob Pike's pattern: bury this error-checking idiom/annoyance in a function
		rtn, err := aFunc()
		ck(err) // one liner; defined (once), somewhere out of the way

		func ck(e error, msg string) {
			if e != nil {
				log.Fatalf("%s: %s", msg, e.Error())
			}
		}

		// @ func return  https://github.com/GoesToEleven/GolangTraining/tree/master/23_error-handling
		return result, fmt.Errorf("error message: %v", err.Error())
	
		// Nest the subject func, e.g., cmd.Run(), in an error-handling func, e.g., must() ...
		must(cmd.Run())  // I.e., must run `cmd.Run()`, which returns nothing UNLESS error
		// where ...
		func must(err error) {
			if err != nil {
				panic(err)
			}
		}

		// @ GoCasts tutorial
		if err != nil {
			fmt.Println("Error:", err)
			os.Exit(1)  // `logFatal` and `logFatal` functions call this
		}

	// BEHAVIOR|TYPE as CONTEXT 
		// https://github.com/ardanlabs/gotraining/blob/master/topics/go/design/error_handling/README.md#code-review
		// https://github.com/ardanlabs/gotraining/blob/master/topics/go/design/error_handling/example2/example2.go

	// ERRORS pkg 
		import "errors"  // `New` method 

		// TYPE is `error`, but ...
		errors.New(err)  // type `*errors.errorString`, but ... 
		// return type `error`, e.g., `foo(...) (valType, error) {...}` 

			// PATTERNs
			func foo(...) (valType, error) {  
				...
				val, ok := cache.Lookup(key)
				if !ok {
					err = errors.New("The cache key, "+key+", does not exit.") 
				}
				return val, err
			} 

			var ErrMath = errors.New("Arg was a heretical NEGATIVE value!")
			func foo(f int) (int, error) {
				if f < 0 {
					return 0, ErrMath
				}
				return f, nil
			}

	// CUSTOM ERROR TYPE
	// https://github.com/GoesToEleven/GolangTraining/tree/master/23_error-handling/03_custom-errors

	// NET ERRORs; network errors
		OpError  // https://golang.org/pkg/net/#OpError

		io.EOF // the `io` pkg ALWAYS RETURNS `io.EOF` ERROR on End-of-file (EOF) condition.
			import "io"  
			in := bufio.NewReader(os.Stdin)
			for {
				r, _, err := in.ReadRune()
				if err == io.EOF { // end-of-file condition; RELIABLE
					break          // finished reading
			}

// INTERFACEs
/*  
	An abstraction allowing any number of unreferenced behaviors, on unreferenced underlying (concrete) types, to implement their type-specific behaviors through a common (abstract) type. Such freedom is called SUBSTITUTABILITY; the siren song of object-oriented programming (OOP). The distinction is that Go interfaces are referenced implicitly. That is, implementing an interface REQUIRES NO ACCESS TO ITS CODE, and the IMPLEMENTATION code AFFECTS NEITHER THE INTERFACE NOR ANY OTHER CODE implementing it. Conversely, a new interface can be created and implemented without modifying existing underlying types (receivers) or their behaviors (function bodies). Where OOP languages superglue objects to behaviors (types to methods, all nested in classes), Go leaves the underlying (receiver) types and their behaviors (function bodies) unmolested, requiring only the IMPLICIT REFERENCE (method name) SATISFYING (IMPLEMENTING) the interface signature (of the same name). 
	
	Thereby, the painful cost of rigidity inherent in OOP languages is low in Go. Also in OOP languages is the ever-present threat of mutability; classes and such, whether "protected" or otherwise, can be modified (downstream), having global (catastrophic) effect. Both such OOP "hells", its ironic mix of rigidity and mutability, are entirely nonexistent with Go's interfaces.  

	Interfaces having only one or two methods are common; convention is to name by appending `er` to the method name, e.g., `Writer` for something that implements `Write`.

	This main "style" of Golang interfaces are only needed when there are two or more concrete types that must be dealt with in a uniform way. Or, when an interface is satisfied by a single concrete type but the interface is in a separate package, perhaps due to dependencies. In such cases, an interface may be used to decouple the two packages. 
	
	There is a second "style" of Go interfaces; those used as a "union" of concrete types, whereof TYPE ASSERTIONS are tested per "TYPE SWITCH" statements (analogous to a swtich statement used as an if-then chain); such interfaces are described as DISCRIMINATED UNIONS.
	
	Interfaces are also USED EXTENSIVELY in MOCKing, e.g., in test-driven development (TDD), where the test uses a MOCK/STUB version of a "real" function (contituent in whatever target process is being tested). 

	Dog/Cat/Speak  https://play.golang.org/p/yGTd4MtgD5 
	A Tour of Go   https://play.golang.org/p/R9p7xf5z568

	https://github.com/GoesToEleven/GolangTraining/blob/master/21_interfaces/00_notes.txt 
	https://github.com/GoesToEleven/GolangTraining/tree/master/21_interfaces
*/
	// Interfaces as CONTRACTs
	// E.g., the `io.Writer` interface defines the contract between `Fprintf` and its callers.

	type Writer interface {
	    Write(p []byte) (n int, err error)
	}
    // The CONTRACT REQUIRES that the caller provide a value of a concrete type THAT HAS A METHOD called `Write` WITH THE APPROPRIATE SIGNATURE and behavior, such as `*os.File` or `*bytes.Buffer`. If the caller satisies that, then the contract guarantees `Fprintf` will do its job.
	type ByteCounter int  // define CONCRETE TYPE of the caller, `c`. 
	// Type `*ByteCounter` satisfies the io.Writer contract
	func (c *ByteCounter) Write(p []byte) (int, error) {
		*c += ByteCounter(len(p)) // convert int to ByteCounter
		return len(p), nil
	}

	// INTERFACE TYPEs 
		// An interface type (an abstract type) specifies A SET OF METHOD SIGNATURES (a METHOD SET) that a CONCRETE TYPE must possess (SATISFY/IMPLEMENT) to be considered an instance of that interface. As a shorthand, Go programmers often say that a CONCRETE TYPE "IS A" particular INTERFACE TYPE, meaning that it satisfies (implements) the interface. E.g., 
		
			// A `*bytes.Buffer` is an `io.Writer`.
			// An `*os.File` is an `io.ReadWriter`.  
		
		// Recall: method type `*T` can be called on argument of type `T`
		
		// Interfaces can be EMBEDDED 
			type ReadWriter interface {
				Reader            // interface
				Writer            // interface
			}

		// The empty interface serves as a general container type:
		// https://blog.golang.org/json-and-go  
			var i interface{}
			i = "a string"
			i = 2011
			i = 2.777
			
			// TYPE ASSERTION :: accesses the underlying concrete type:
			r := i.(float64)
			fmt.Println("the circle's area", math.Pi*r*r)
			
			// Or, if the underlying type is unknown, a type switch determines the type:
			var (
				j   []byte
				err error
			)
			switch v := i.(type) {
				case int:
					fmt.Println("twice i is", v*2)
				case float64:
					fmt.Println("the reciprocal of i is", 1/v)
				case string:
					if s, ok := i.(string); ok {
						j = []byte(s)
					} else {
						return errors.New("wtf @ type assertion")
					}
				default:// i isn't one of the types above
					j, err = json.Marshal(i)
					if err != nil {
						return err
					}
				default:
			}

			var i interface{} = "hello"

			s, ok := i.(string)
			fmt.Println(s, ok)  // hello true

			f, ok := i.(float64)
			fmt.Println(f, ok)  // 0 false 

			f = i.(float64)     // panic
			fmt.Println(f)


	// ASSIGNABILITY RULE
		// an expression may be assigned to an interface only if its type satisfies the interface.
			var w io.Writer
			w = os.Stdout           // OK: *os.File has Write method
			w = new(bytes.Buffer)   // OK: *bytes.Buffer has Write method
			w = time.Second         // compile error: time.Duration lacks Write method

	// INTERFACE TYPE DECLARATION 
	/* 
		A list of method signatures; a signature is a method name & its associated types. Confusingly, the method signature(s) comprising an interface, and the function/receiver/method(s) definition(s) containing them, are both  refered to simply as "method". Moreover, regarding a function defining receiver `r` on method `iMethod1`, it's refered to as "method  iMethod1", "method r.iMethod1", and "function r.iMethod1". 
	*/
		type iFace interface {    // (a set of) method signature(s)
			iMethod1() string         // signature 
			iMethod2(depth int) bool  // signature 
		}
		func (r rType) iMethod1() string {/* body */}  
		// The "method name" is `iMethod1`; the function-method name is `r.iMethod1`  

		// E.g.,
			type shape interface { 
				area() float64   // method SIGNATURE
			}
			// NOTE interface `shape` is NEVER explicitly referenced

			type square struct { // STRUCT of TYPE `square`
				side float64
			}
			type circle struct { // STRUCT of TYPE `circle`
				radius float64
			}

			func (x square) area() float64 {
				return x.side * x.side
			}
			func (x circle) area() float64 {
				return math.Pi * x.radius * x.radius
			}

			func main() {
				s := square{7}
				c := circle{4}
				fmt.Println(s, s.area())  // {7} 49
				fmt.Println(c, c.area())  // {4} 50.26548245743669
			}

		// E.g., @ "sort" package
		// https://github.com/GoesToEleven/GolangTraining/tree/master/21_interfaces/02_package-sort

		// E.g., @ VALUE vs. POINTER RECEIVERs
		// https://github.com/GoesToEleven/GolangTraining/tree/master/21_interfaces/04_method-sets

		// E.g., STRINGERs  https://tour.golang.org/methods/17
			// defined by the "fmt" package; a ubiquitous interface used to print values
			// this is how `fmt.Println`, etc, ACCEPTs ANY TYPE.
			type Stringer interface {
				String() string
			} // any [CUSTOM] DEFINED METHOD thereof AUTOMATICALLY IMPLEMENTS this INTERFACE
			// e.g., 
			type Person struct {
				Name string
				Age  int
			}
			func (p Person) String() string { // `p` implements `Stringer`  per `String()`
				return fmt.Sprintf("%v (%v years)", p.Name, p.Age)
			}
			func main() {
				fmt.Println(Person{"Arthur Dent", 42}) // Arthur Dent (42 years)
				//replacing `String()` w/ `Foo()` prints: {Arthur Dent 42}
			}			
		// E.g., for custom type,`IPAddr`, a 4 element array of type `byte` ...
		type IPAddr [4]byte
		// ... add this `String() string` method to `IPAddr`
		func (ip IPAddr) String() string {
			return fmt.Sprintf("%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3])
		} // https://tour.golang.org/methods/18

	// EMPTY INTERFACE (type); very useful and prevalent, e.g., 
		func Fprintf(w io.Writer, format string, args ...interface{}) (int, error) 

		// ALL TYPES SATISFY the EMPTY INTERFACE type
		var i interface{}            // generalized container; may hold values of ANY type.
			i = 42                   // (42, int) ... as a tuple: (value, underlying-type)
			i = "hello"              // (hello, string)
		func f(i interface{}) {...}  // Accepts ANY type arg; inside f, i is type interface{}.

	// INTERFACE VALUEs
	/* 
		A variable of (abstract) type `interface` has TWO components:  

			1. A CONCRETE TYPE; interface's DYNAMIC TYPE
			2. A VALUE of that type; interface's DYNAMIC VALUE

			Thus, interface values are constructed of TWO WORDS OF DATA; one word is used to point to the interface's method table for the value's underlying (dynamic) type; the other word is used to point to the actual data being held by that (dynamic) value; https://tour.golang.org/methods/11   

			Think of it as a tuple  (value, type)            
	*/
		var say interface{}
		say = "foo"  // (foo, string)
		say = 123    // (123, int)

		// Interface values have `nil` UNDERLYING VALUES
		// avoids null pointer exceptions  https://tour.golang.org/methods/12
			type I interface {M()}; func (t *T) M() {...}

		// TYPE ASSERTIONs  https://notes.shichao.io/gopl/ch7/#type-assertions
			x.(T)  // an operation applied to an INTERFACE VALUE;  where `x` is an expression of an interface type and `T` is a type, called the ASSERTED TYPE. 
			/*
				A type assertion checks that the dynamic type of its operand matches the asserted type; if the asserted type `T` is a concrete type, then the type assertion checks whether that is x's dynamic type. Panics if not.
			*/
			s := i.(string)       // hello
			s, ok := i.(string)   // hello, true
			f, ok := i.(float64)  // 0, false
			f = i.(float64)       // panic: interface conversion: interface {} is string, not float64
			
			// TEST using TYPE ASSERTION  https://notes.shichao.io/gopl/ch7/#type-assertions 
				var w io.Writer = os.Stdout
				f, ok := w.(*os.File)       // ok: true,  f: &{0x1043c080} ; ok
				b, ok := w.(*bytes.Buffer)  // ok: false, b: <nil>         ; !ok
				// need to catch error, else
				b := w.(*bytes.Buffer)      // "panic: interface conversion: io.Writer is *os.File, not *bytes.Buffer"
				
				// Idiom ...
					if f, ok := w.(*os.File); ok {
						// ...use `f` if `ok` is `true`
					}

			// TYPE SWITCH "style" of Interface  https://notes.shichao.io/gopl/ch7/#type-switches
				// A switch statement for TYPE ASSERTIONS; types, not values, per case; 
				// Values COMPARED AGAINST that of the INTERFACE VALUE; 
				// Permits several type assertions/tests in series; 
				// analogous to switch statement used as an if-then chain
				func foo(i interface{}) ... {
					switch v := i.(type) {
					case T:
							// here v has type T
					case S:
							// here v has type S
					default:
							// no match; here v has the same type as i
					}
					...
				}

	// REFLECTION
		import "reflect"  // used for determining information at runtime.

// CONCURRENCY
/*
	CONCURRENT PROGRAMMING; the expression of a program as A COMPOSITION OF SEVERAL AUTONOMOUS ACTIVITIES; independently executing pieces; Go has 3 concurrency elements:
	
		GOROUTINEs  (execution)
		CHANNELs    (communication) 
		SELECT      (coordination)
	
	Values are passed between independent activities (goroutines) but variables are for the most part confined to a single activity; COMMUNICATION is the SYNCHRONIZER; Ref: Hoare's Communicating Sequential Processes (CSP); a type-safe generalization of Unix pipes. PARADIGM of Go/CSP: "Do not communicate by sharing memory; instead, share memory by communicating."

		A Tour of Go    https://tour.golang.org/concurrency/1
		Go by Example   https://gobyexample.com/ 
		MutexOrChannel  https://github.com/golang/go/wiki/MutexOrChannel   (When to use)

		For SYNCHRONIZATION :: Mutex (sync), Atomic (sync/atomic) 
		For ORCHESTRATION   :: Channels (for SIGNALing; not queing) 
			UNFUFFERED for GUARANTEED delivery, but COST is UNKNOWN LATENCY  
			BUFFERED for lower latency, but RISK of no delivery, which grows with buffer size.

			Channel Design Patterns  https://github.com/ardanlabs/gotraining/tree/master/topics/go/concurrency/channels 
*/
	// MUTEX
	/*
		Mutual Exclusion (Lock); data structure that ensures only one goroutine can access a variable at a time; avoid conflicts, sans communication (channels).  
		https://tour.golang.org/concurrency/9 
		https://notes.shichao.io/gopl/ch9/#mutual-exclusion-syncmutex
	*/
		synch.Mutex  // https://golang.org/pkg/sync/#Mutex  

	// GOROUTINEs
		// a "lightweight thread" managed by the Go runtime; "goroutines" because existing terms (threads, coroutines, processes, ...) convey inaccurate connotations. A goroutine has a simple model: a function EXECUTING CONCURRENTLY with other goroutines IN the same, SHARED ADDRESS SPACE. Goroutines are lightweight, costing little more than the allocation of stack space; the stacks start small (cheap), and grow/shrink by allocating/freeing heap storage, as required. Goroutines are multiplexed onto multiple OS threads so if one should block, such as while awaiting I/O, others continue to run. Their design hides many of the complexities of thread creation and management. Go's runtime system handles all that.
			go f(x, y, z)  // create a new goroutine that calls `f(x, y, z)`; DON'T WAIT  
		/*
		The EVALUATION of f, x, y, and z happens in the CURRENT goroutine.
		The EXECUTION of f happens in the NEW goroutine.
		When the call completes, the goroutine EXITS, SILENTLY.
		Similar to `&` notation of Unix shell, which runs a BACKGROUND PROCESS.

		As of version 1.8, every goroutine is given an initial 2KB block of CONTIGUOUS MEMORY; its STACK space. This initial stack size has changed over the years and could change again in the future.  https://www.ardanlabs.com/blog/2017/05/language-mechanics-on-stacks-and-pointers.html

		GO SCHEDULER 

			By default, Go scheduler tries to use only 1 CPU core. 
			Can modify setting to use multiple cores.

			Go Scheduler runs 1 Goroutine per 1 CPU core.
			Go Scheduler runs ONE routine until it finishes OR makes a blocking call, e.g., HTTP request. If blocking call, then pauses that goroutine and starts the next goroutine in the queue. Thus CONCURRENT. if goroutine finished, then it starts next goroutine in queue. NOT in PARALLEL. Thus, "concurrency is NOT parellelism." 

			All goroutines spawned in main(){...} are CHILDren of that MAIN goroutine. Program terminates as soon as MAIN ends; doesn't wait for child goroutines.

		SHARED ADDRESS SPACE
			Though goroutines run concurrently in the SAME ADDRESS SPACE, Go's runtime system ensures only one goroutine has access to the value at any given time. Shared VALUES are passed around on CHANNELS; MEMORY IS NEVER ACTIVELY SHARED by separate threads of execution. Thus, data races cannot occur, by design. Channel communication is the main method of synchronization between goroutines.

		REFs
			Effective Go  https://golang.org/doc/effective_go.html#goroutines
			GoesToEleven  https://github.com/GoesToEleven/GolangTraining/tree/master/22_go-routines
		*/

		// "Go for Industrial Programming" 2018 by Peter Bourgon
		// LIFECYCLE MANAGEMENT of Goroutine is ESSENTIAL to prevent memory leaks. 
		// https://peter.bourgon.org/go-for-industrial-programming/#goroutine-lifecycle-management  
		// Goroutine is very low-level, and most implementations tend to suck.
		// DO NOT START a goroutine unless/until its ending is also known, else memory LEAK
			go executeFunc, interruptFunc  // CONCEPTUAL only.  https://www.youtube.com/watch?v=PTE4VJIdHPg  
		
			// oklog/run :: https://github.com/oklog/run // https://godoc.org/github.com/oklog/run#Group.Add
			func (g *Group) Add(execute func() error, interrupt func(error)) 

			// gopkg.in/tomb.v2 :: https://godoc.org/gopkg.in/tomb.v2  https://gopkg.in/tomb.v2 
			// tomb handles clean goroutine tracking and termination. 

		// Future :: Golang implements futures // Async/Await (EQUIV to Future) 
			future := make(chan int, 1)
			go func() { future <- process() }() // Async
			result := <- future                 // Await

		// Scatter/Gather :: Web crawl with total time ~ time of slowest (ONE) site return
			// Scatter
			c := make(chan result, 10)
			for i := 0; i < cap(c); i++ {
			    go func() {
			        val, err := process()
			        c <- result{val, err}
			    }()
			}

			// Gather
			var total int
			for i := 0; i < cap(c); i++ {
			    res := <-c
			    if res.err != nil {
			        total += res.val
			    }
			}

		// A FUNCTION LITERAL can be handy in a goroutine invocation. In Go, function literals are CLOSUREs: the variables referred to by the function survive as long as they are active.
			func Announce(message string, delay time.Duration) {
				go func() {
					time.Sleep(delay)
					fmt.Println(message)
				}()  // Note the appended `()`; must call the [anonymous] function.
			}
		// ... has NO WAY OF SIGNALING COMPLETION; impractical; 
		// Goroutine remains FOREVER (leaks resources) UNLESS completed/closed. Thus need CHANNELS.
			// Unlike garbage variables, leaked goroutines are not automatically collected, so it is important to make sure that goroutines terminate themselves when no longer needed.

		// Pattern :: run 
			go func() { /* non-blocking code */ }
			select{} // block 

		// Pattern :: go test ...  
			// @ Profiler / Debugger 
			import _ "profiling"
			// @ pprof
			import _ "net/http/pprof"
			func init() {
			go func() {
				log.Println(http.ListenAndServe("localhost:6060", nil))
			}()
			}

		// CANCELLATION of GOROUTINES is a BIG, largely unsolved, PROBLEM in golang.
		// CONTEXT pkg (https://blog.golang.org/context) was created (2014) to solve this:
			// https://www.ardanlabs.com/blog/2019/09/context-package-semantics-in-go.html
			// https://medium.com/@cep21/how-to-correctly-use-context-context-in-go-1-7-8f2c0fafdf39
			// ... has issues: https://faiface.github.io/post/context-should-go-away-go2/

	// CHANNELs
	/*
		Channel communication is the main method of synchronization between goroutines. A channel is a TYPED conduit through which VALUES are SENT and RECEIVED; per CHANNEL OPERATOR, `<-`. Channels are a reference to an underlying data structure. Both sends and receives BLOCK until the other side is ready. This allows goroutines to synchronize without explicit locks or condition variables; combines COMMUNICATION with SYNCHRONIZATION, thus COMMUNICATION IS THE SYNCHRONIZER; an exchange of a value, guaranteeing the pair of data (memory) are in a known state. I.e., "Share memory by communicating"; a channel can function sans goroutine.

			Non-buffered channels block. 
			Read (receive) blocks when no value is available.
			Write (send) blocks until there is a read.

			Write to buffered channel does not block until buffer-size unread values written.

		BLOCKing & BUFFERs

			RECEIVER: 
				Blocks until there is data. 
				So, a receiver of a buffered channel (buffered sender) blocks whenever buffer is empty.
			
			SENDER:
				UNBUFFERED: 
					Blocks until a receiver has received the value (from a channel).
				BUFFERED: 
					Blocks until the value has been copied to its buffer; if its buffer is full, then waits/blocks until a receiver has retrieved a value; 
					BUFFERED CHANNEL: 
						a channel having a BUFFERED SENDER 
						https://notes.shichao.io/gopl/ch8/#buffered-channels  

			SEMAPHORE
				Channels can act as semaphores; a variable or abstract data type used to control access to a common resource by multiple processes in a concurrent system. E.g., counting the number of available resources.

				COUNTING SEMAPHOREs; such are equipped with two operations, `wait` and `signal`, conventionally denoted as P (wait/decrement) and V (increment) respectively; S(P,V); associated queue (FIFO process) @ zero or negative P.

		PIPELINEs 
			Formed by channels connecting goroutines together (though Go has no formal definition); the output of one is the input to another; a series of STAGES (GROUP of GOROUTINES) connected by CHANNELS; receive values from UPSTREAM via INBOUND CHANNELS, and perform some function on that data, usually producing new values, and send values DOWNSTREAM via OUTBOUND CHANNELS; first stage has only OUTBOUND channels; last stage has only INBOUND; first stage oft called SOURCE or PRODUCER; last stage, called SINK or CONSUMER.

			https://blog.golang.org/pipelines
			https://github.com/GoesToEleven/GolangTraining/blob/master/22_go-routines/12_channels_pipeline/02_sq-output/main.go

			FAN OUT:
				Multiple functions reading from the same channel until that channel is closed.  https://github.com/GoesToEleven/GolangTraining/tree/master/22_go-routines/13_channels_fan-out_fan-in

			FAN IN:
				A function can read from multiple inputs and proceed until all are closed by MULTIPLEXING the INPUT CHANNELS onto a single channel that's closed when all the inputs are closed.  https://github.com/GoesToEleven/GolangTraining/tree/master/22_go-routines/13_channels_fan-out_fan-in

			Note:
			- stages close their outbound channels when all the send operations are done.
			- stages keep receiving values from inbound channels until those channels are closed.

			EXPLICIT CANCELLATION should be used
				In real pipelines, receiver may only need a subset of values, or a stage exits early because an inbound value represents an error in an earlier stage. In either case the receiver should not have to wait for the remaining values to arrive; we want earlier stages to stop producing values that later stages don't need. If a stage fails to consume all the inbound values, the goroutines attempting to send those values could block indefnitely. This is a RESOURCE LEAK; must design such that goroutines exit on their own. Buffers can be used, but are brittle (require correct size). The solution is EXPLICIT CANCELLATION: Use a second, "done", channel as a kind of SEMAPHORE.

		REFs
			Go by Example  https://gobyexample.com/channels
			A Tour of Go   https://tour.golang.org/concurrency/2
			Effective Go   https://golang.org/doc/effective_go.html#channels
			GoesToEleven   https://github.com/GoesToEleven/GolangTraining/tree/master/22_go-routines/09_channels
	*/ 
	// CHANNEL OPERATOR a.k.a. RECEIVER OPERATOR, `<-`, and its operands
		TARGET <- SOURCE  // https://golang.org/ref/spec#Receive_operator

		chan<-   // TO channel; PRODUCERs      SEND
		<-chan   // FROM channel; CONSUMERs    RECEIVE
		// E.g.,
			ch<- val     // SEND value TO CHANNEL.
			val = <-ch   // RECEIVE value FROM CHANNEL, and ASSIGN it to `val`.
			val := <-ch  // RECEIVE value FROM CHANNEL, and DECLARE+ASSIGN it to `val`.
			<-ch         // RECEIVE value FROM CHANNEL, and DISCARD it.
			// NOTE syntax (spacing): space okay ONLY ON SEND; `ch <- val`
			
			// VARIANT of RECEIVE OPERATION (expression)
			x, ok := <-ch  // `ok` is UNTYPED BOOLEAN RESULT; 
			// `true` if the communication succeeded;
			// `false` if channel is closed AND empty (drained). 

			// i.e., RECEIVERs can TEST for CLOSEd channel
				// https://golang.org/ref/spec#Receive_operator  
				// Channels usually needn't be closed, unlike files;
				// exceptions, e.g., end of a RANGE LOOP.

	// CHANNEL TYPEs  https://golang.org/ref/spec#Channel_types  

		// BIDIRECTIONAL channels (DEFAULT) 
		chan T    // can SEND & RECEIVE values of type T; 
		// UNIDIRECTIONAL channels 
			chan<- T   // can only SEND values of type T
			<-chan T   // can only RECEIVE values of type T
			// NOTE DIFFERENT SYNTAX; no space btwn `<-` and `chan` REGARDLESS
			// E.g., `out` & `in` are unidirectional; sender & receiver respectively 
				func squarer(out chan<- int, in <-chan int) {
					for v := range in {
						out <- v * v  // SEND value to channel 
					}
					close(out)
				} 

	// CREATE/ALLOCATE CHANNELs per `make()` ELSE nil channel (BAD/WORTHLESS)
		ch1 := make(chan int)            // unbuffered channel of integers
		ch2 := make(chan *os.File, 100)  // buffered channel of pointers to Files

		// E.g.,
			c := make(chan int,1)        // make an integer channel having buffer (capacity) 1
			c <-77                       // send value to channel
			fmt.Printf("%v,",<-c)        // print received value
			// Note no goroutine; would DEADLOCK if unbuffered,
			// since channel has no corresponding concurrent receiver

		// CAPACITY of a channel is BUFFER SIZE
			ch2 := make(chan int, 33)
			cap(ch2)  // 33
			len(ch2)  // 0
			ch <- 44
			len(ch2)  // 1

	// CLOSE a channel; indicates no more values will be sent.
	/*
		ONLY SENDERs close; after a channel has been closed, any further SEND OPERATIONS on it will panic. After the closed channel has been drained (the last sent element has been received), all SUBSEQUENT RECEIVE OPERATIONS will PROCEED WITHOUT BLOCKING, yielding the channel's ZERO VALUE. TEST for CLOSED channel is done INDIRECTLY at RECIEVE operation, by its variant form, `x, ok := <-ch`, which is `false` if closed and empty (drained). 
	*/ 
		close(ch)  // only SENDER can close 
		// NOTE if ...
			x := <-sender // then close `x` NOT `sender`;
			close(x)      // apparently `x` is not merely the value sent, 
			              // but also a rep of `sender` CHANNEL

		// UNINITIALIZED channel VALUE is `nil` BUT panics if read 
		ch := make(chan int)
		fmt.Println(<-ch)  // "fatal error: all goroutines are asleep - deadlock!"
		close(ch)          // BUT after `ch` CLOSED (+drained), its zero-value is returned 
		fmt.Println(<-ch)  // 0 
		fmt.Println(<-ch)  // 0 
		... 
		// See EXPLICIT CANCELLATION, which exploits this. 

	// CHANNEL AXIOMS  https://github.com/a8m/go-lang-cheat-sheet#channel-axioms
		// A send to a nil channel blocks forever
		// A receive from a nil channel blocks forever
		// A send to a closed channel panics
		// A receive from a closed channel returns the zero value immediately

	// E.g., Looping in Parallel  https://notes.shichao.io/gopl/ch8/#looping-in-parallel 

	// RANGE over CHANNEL
		func main() {
			c := make(chan int, 10)
			go fibonacci(cap(c), c)  // cap(c) is 10; n
			for i := range c {       // RECEIVES UNTIL CLOSED
				fmt.Println(i)
			}
		}
		// ... without `close(c)`, above, this FAILs:
		// "fatal error: all goroutines are asleep - deadlock!"
		func fibonacci(n int, c chan int) {
			x, y := 0, 1
			for i := 0; i < n; i++ {
				c <- x  // SEND x to channel c, per iteration
				x, y = y, x+y
			}
			close(c)    // must CLOSE channel to end RANGE LOOP
		} 

	// CHANNEL SYNCHRONIZATION
		// E.g., use channel to communicate completion of a process (goroutine)
		c := make(chan int)  // Allocate a channel.
		// Start sort in a goroutine; when it completes, signal on the channel.
		go func() {
			list.Sort()
			c <- 1  // Send a signal when done; value does not matter.
		}()
		doSomethingForAWhile()
		<-c   // Wait for sort to finish; discard sent value.

		// E.g., use channel to send result of process (goroutine); sum the values of a slice, per channel
		/*
			Note DESIGN PATTERN for goroutine/channel: separate func, outside main func, that is run (called) per goroutine, from which data is SENT; main func, where channel is created, goroutine is launched, and data is RECEIVED. 

			Alternate pattern: if called only once, use ANONYMOUS, auto-executing func as goroutine @ `main()`; `go func([params]){}([args])`. E.g., see CLOSUREs below.
		*/ 
			func sum(s []int, c chan int) {  // SENDER (PRODUCER) 
				sum := 0
				for _, v := range s {
					sum += v
				}
				c <- sum // send sum to channel
			}
			func main() {                   // RECEIVER (CONSUMER); @ `main()` 
				s := []int{7, 2, 8, -9, 4, 0}

				c := make(chan int)      // create a [blocking] channel
				go sum(s[:len(s)/2], c)  // second half of slice
				go sum(s[len(s)/2:], c)  // first half of slice
				x, y := <-c, <-c         // receive from c

				fmt.Println(x, y, x+y)   // 2nd, 1st, sum
			}

	// CLOSUREs with GOROUTINEs  [closure-binding]
		// Goroutines may survive beyond a loop iteration, so a separate
		// instance of loop var is needed for each one; for each iteration.

		// ISSUE :: LOOP VARIABLE CAPTURE 
		/*
			The `for` loop introduces a new LEXICAL BLOCK in which its iteration variable is declared. All function values created by this loop "capture" and share the same variable, which is an addressable storage location, not its value at that particular moment. By the time some inner function is called, the (captured) iteration variable (NOT passed as ARG of inner func) may hold some unexpected (final) value. This issue is NOT limited to range loops or closures or goroutines.
		*/
		// E.g., RANGE over goroutine
			values := []string{"a", "b", "c"}
			for _, v := range values {
				go func() {
					fmt.Printf(v)       // "ccc"; loop ended before goroutine evaluated
				}()
			}
			// SOLUTION 1: variable shadowing
				for _, v := range values {
					v := v  // SHADOW the LOOP VAR; `v` is anew per iteration
					go func() {
						fmt.Printf(v)   // "cab" 
					}()
				}
			// SOLUTION 2: use dummy `u` PARAM; pass `v` as ARG
				for _, v := range values {
					go func(u string) { 
						fmt.Printf(u)   // "cab"
					}(v)
				} 
				// NOTE instead of `u` PARAM, shadow `v` there okay too

			time.Sleep(1 * time.Millisecond)  // @ `main()`; prevents from ending before goroutine

	// PIPELINE  https://notes.shichao.io/gopl/ch8/#pipelines 
	// I.e., like Unix Pipes :: `counter | naturals | squares` 
		naturals := make(chan int)
		squares := make(chan int) 

		// Counter
	    go func() {
	        for x := 0; x < 100; x++ {
	            naturals <- x
	        }
	        close(naturals)
	    }()

	    // Squarer
	    go func() {
	        for x := range naturals {
	            squares <- x * x
	        }
	        close(squares)
		}()
		
	    // Printer (in main goroutine)
	    for x := range squares {
	        fmt.Println(x)
	    }

	// COUNTING SEMAPHORE 
	/*
		To limit parallellism; limit use of machine resources; model the primitive (counting semaphore) USING a BUFFERED CHANNEL of capacity `n`. Conceptually, each of the `n` vacant slots represents a token entitling the holder to proceed. Sending a value into the channel acquires a token, and receiving a value releases a token, creating a new vacant slot.
	*/
		// E.g.,  https://notes.shichao.io/gopl/ch8/#example-concurrent-web-crawler
			// `tokens`; a counting semaphore used to enforce a limit of 20 concurrent requests.
			var tokens = make(chan struct{}, 20)

			func crawl(url string) []string {
				fmt.Println(url)
				tokens <- struct{}{}           // acquire a token
				list, _ := links.Extract(url)
				<-tokens                       // release the token

				return list
			}

	// PARALLELIZATION per CPUs   https://golang.org/doc/effective_go.html#parallel 
		import "runtime"
		 
		type Vector []float64  
		var numCPU = runtime.NumCPU() 

		// Apply the operation to v[i], v[i+1] ... up to v[n-1].
		func (v Vector) DoSome(i, n int, u Vector, c chan int) {
			for ; i < n; i++ {
				v[i] += u.Op(v[i])
			}
			c <- 1   // signal that this piece is done
		} 

		func (v Vector) DoAll(u Vector) {
			c := make(chan int, numCPU)  // Buffering optional but sensible.
			for i := 0; i < numCPU; i++ { 
				// divide it up into TOTAL/#-of-CPUs
				go v.DoSome(i*len(v)/numCPU, (i+1)*len(v)/numCPU, u, c)
			}
			// Drain the channel.
			for i := 0; i < numCPU; i++ {
				<-c    // wait for one task to complete
			}
			// All done.
		}

	// SELECT (/CASE) statement
	/* 
		Wait on multiple channels. The first one received "wins"; its case executes.

		BLOCKS UNTIL ONE of its cases can run, then executes that case, thus MULTIPLEXes (from a set of possible SEND or RECEIVE operations; coded scenarios); similar to `switch` statement, but CASES refer to COMMUNICATION operations [CHANNELs]; thus a goroutine can be coded to wait on multiple communication operations. If multiple cases are ready, then one is randomly chosen. 
		
		DEFAULT case executes IF NO other CASE is READY.  
	*/
		select {
			case <-ch1:
				// ...
			case x := <-ch2:
				// ...use x...
			case ch3 <- y:
				// ...
			default:
				// ...
		}

		// FOR-SELECT LOOP; its basic/typical structure:  https://youtu.be/QDDwwePbDtw?t=15m54s
		for { select { case ch-expr: ... } } // no data races; one goroutine

			// E.g., TIMERs  https://tour.golang.org/concurrency/6  https://gobyexample.com/timers
				func main() { // select/case @ 2-blocking-channels example
					tick := time.Tick(100 * time.Millisecond)
					boom := time.After(500 * time.Millisecond)
					for {             // forever [until `return`]
						select {      // execute first case ready; first channel received
						case <-tick:  // if tick case ready
							fmt.Println("tick.")
						case <-boom:  // if boom case ready
							fmt.Println("BOOM!")
							return    // only if boom case executed
						default:      // only if neither tick/boom ready; i.e., between ticks
							fmt.Println("    .")
							time.Sleep(50 * time.Millisecond)  // pause [pseudo-blocking]
						}
					}
				}  // Note: Neither Select nor Channels require any Goroutine.

			// E.g., `time.After()`; useful @ select/case; sets max timeout 
			// @ TDD  https://github.com/quii/learn-go-with-tests/blob/master/select.md#slow-tests
				func Racer(a, b string, timeout time.Duration) (winner string, error error) {
					select {
					case <-ping(a):
						return a, nil
					case <-ping(b):
						return b, nil
					case <-time.After(timeout):
						return "", fmt.Errorf("timed out waiting for %s and %s", a, b)
					}
				}


	// EXPLICIT CANCELLATION  
	/*
		E.g., @ pipelines; because there is no way for one goroutine to terminate another directly; shared variables in undefined states. 

		How to cancel multiple goroutines: BROADCAST AN EVENT over a channel; create a CANCELLATION CHANNEL; a broadcast mechanism: never send/recieve on it, but rather SIGNAL BY CLOSING IT, so it can then be read/received (safely) by everyone (over and over again), returning its zero-value. (When a channel is closed and drained of all sent values, subsequent receive operations proceed immediately, yielding zero values.) 
		https://notes.shichao.io/gopl/ch8/#cancellation   
	*/ 
		var done = make(chan struct{})  // CANCELLATION CHANNEL 

		func cancelled() bool {
			select {
			case <-done:
				return true
			default:
				return false
			}
		} 
		// its closing broadcasts that the subject event terminated.
		go func() {
			os.Stdin.Read(make([]byte, 1)) // read a single byte
			close(done)  // nothing was ever sent/received over channel `done`
		}()

	// WAITGROUP  See `synch` package @ "# PACKAGEs" (below) 
	/*
		To know when the last goroutine has finished (which may not be the last one to start), we need to increment a counter before each goroutine starts and decrement it as each goroutine finishes. This demands a SPECIAL KIND OF COUNTER that CAN BE SAFELY MANIPULATED FROM MULTIPLE GOROUTINES and that provides a way to wait until it becomes zero. This counter type is known as `sync.WaitGroup` 
	*/
		sync.WaitGroup  // A special counter; `WaitGroup` waits for a collection of goroutines to finish. 

	// EXAMPLEs 
		// @ GoPL book
			// Web Crawler  https://notes.shichao.io/gopl/ch8/#example-concurrent-web-crawler 
			// Dir Traversal  https://notes.shichao.io/gopl/ch8/#example-concurrent-directory-traversal 
			// Multiplexing w/ Select  https://notes.shichao.io/gopl/ch8/#multiplexing-with-select 
			// Chat Server  https://notes.shichao.io/gopl/ch8/#example-chat-server

		// Leaky (reusable) Buffer (list);  https://golang.org/doc/effective_go.html#leaky_buffer

	// CONCURRENCY PATTERNs
		// Google I/O 2012 - Go Concurrency Patterns  https://www.youtube.com/watch?v=f6kdp27TYZs
		// Google I/O 2013 - Advanced Go Concurrency Patterns 
		// (a.k.a. How to Prevent Goroutine Leaks) https://www.youtube.com/watch?v=QDDwwePbDtw
	    // per Go CONCURRENCY PRIMITIVES: Goroutine, Channel, Select

		// Generator: function that returns a channel
		// Multiplexing: combine channels into a channel;
		func fanIn(ch1, ch2 <-chan string) <-chan string {
			c := make(chan string)
			go func() { for { c <- <-ch1 } }()
			go func() { for { c <- <-ch2 } }()
			return c
		} 
		// Restoring Sequencing: send a channel on a channel, make goroutine wait
			type Message struct {
				str string
				wait chan bool
			}
			for i :=0; i < 5; i++ {
				msg1 := <-c; fmt.Println(msg1.str)
				msg2 := <-c; fmt.Println(msg2.str)
				msg1.wait <- true
				msg2.wait <- true
			} 
		// where channel is ...
			waitForIt := make(chan bool)  // Shared btwn all messages
			c <- Message{ fmt.Sprintf("%s: %d", msg, i), waitForIt }
			time.Sleep(time.Duration(...) * time.Millisecond)
			<-waitForIt

		// Select: a control structure, like a switch, but
		// each case is a communication; unique to concurrency
			select { // blocks until one comm can proceed;
				case v1 := <-c1:
				…
				case v2 := <-c2:

				default:
				… // optionally; executes immediately if none ready
			}
		// used, e.g., to REDUCE Multiplexing pattern to ONE go routine, or ...
		// Timeout: set max wait time
		// Quit: explicitly quit per select/case
		// Replication: avoid timeout/discards by using multipe goroutine clones

		// Lesser problems can be solves w/ simpler tools/pkgs:
		// "synch" and "synch/atomic" provide MUTEXes, CONDITION VARIABLEs, etc
		// When to use: synch.Mutex vs. channel  https://github.com/golang/go/wiki/MutexOrChannel

// DEV/DEBUG
	// STACK TRACE; place command @ end of subject code
		panic("show the stacks")  // https://golang.org/doc/effective_go.html#panic
	// RACE DETECTOR
		go run -race foo.go

// PACKAGEs

	import "fmt"  // https://golang.org/pkg/fmt/  
	// I/O @ Go binds to FILE DESCRIPTORs (FD), NOT FILE  
		x = fmt.Sprintf("v: %d\n", val)  // format & print TO STRING, NOT stdout 
		fmt.Printf("v: %d\n", val)       // format & print TO STDOUT  
		fmt.Fprintf(os.Stdout, "%s is %d years old.\n", name, age) // TO FD per io.Writer, per format.
		fmt.Fprint(os.Stdout, name, " is ", age, " years old.\n")  // TO FD per io.Writer, per space-sep
		fmt.Println("v:",val)                    // 1 operand per line; print to stdout  
		fmt.Println(fmt.Sprint("v: %d\n", val))  // nesting; print, to stdout, the formatted string  

		// Scanln() can be used to pause program; wait for user input
			var i string
			fmt.Scanln(&i)

	// VERBs (fmt PRINT OPTIONs)  https://golang.org/pkg/fmt/#pkg-overview 
		"value" %v, "val+syntax" %#v, "key-val-pair" %+v, "type" %T, 
		"pointer-addr" %p, "quoted-esc-literal" %q, "true_false" %t  
			#  // alt format 
			+  // for numerics, print sign regardless 
			+  // for quoted literal, guarantee ASCII 
			-  // pad right; left-justify 
			0  // pad with leading zero 
		// BYTE 
			"bin" %b, "dec" %d, "oct" %o, "char" %c, "U+HHHH '<rune>'" %#U
			b := []byte("\u2627"); fmt.Printf("%d, %#v, %#U, %c\n", b, b, b, b) 
			// [226 152 167], []byte{0xe2, 0x98, 0xa7}, [U+00E2 'â' U+0098 U+00A7 '§'], [â  §]
		// STRING
			"str" %s
		// RUNE 
			"bin" %b, "dec" %d, "oct" %o, "char" %c, "U+HHHH" %U
		// INT 
			"bin" %b, "dec" %d, "oct" %o, "hex" %x, "HEX" %X
		// FLOAT
			%g  // chooses most compact having adequate precision, i.e. %e for large, else %f
			%e  // decimal point with exponent (scientific notation)
			%f  // decimal point sans exponent

			// All three verbs allow control of field width and numeric precision:
				%f     // float; default width, default precision
				%9.2f  // float; width 9, precision 2
				%9.f   // float; width 9, precision 0
				%.8b   // binary; width 8
		
				// E.g.,
					var x uint64 = 1<<64 - 1
					fmt.Printf("%d %x; %T %x\n", x, x, x, int64(x)) 
					//=> 18446744073709551615 ffffffffffffffff; uint64 -1 

		// E.g.,
			fmt.Printf("\n  '%c' '%U' '%s' '%d' '%.3v...'\n", '\u2627', '☧', "Foo bar.", 'Z', 1.1234)  
			//=> '☧' 'U+2627' 'Foo bar.' '90' '1.12...'

			for i := 32; i < 256; i++ {
			// printable ASCII range of UTF-8 Code Points; 32-255
				// %d:dec, %q:single-quot-char-lit, %b:bin, %o:oct, %x:hex, %U:Unicode
				fmt.Printf("%d \t %q \t %b \t %o \t %x \t %U \n", i, i, i, i, i, i)
			}
			// 65       'A'     1000001         101     41      U+0041
			// 90       'Z'     1011010         132     5a      U+005A
			// 97       'a'     1100001         141     61      U+0061
			// 122      'z'     1111010         172     7a      U+007A
			// 208      'Ð'     11010000        320     d0      U+00D0
			string(65)   // `A`

	import  "os"     // https://golang.org/pkg/os/
		var Args []string  // signature @ os package
		os.Args        // array containing command line args (and program path)
		os.Args[0]     // program (self) path [string]
		os.Args[1:]    // slice containing positional params (args) [][string]
		// https://golang.org/pkg/os/#pkg-variables

		if len(os.Args) > 1 {/* then args passed from command line */}
		if len(os.Args) < 2 {/* then no args passed from command line */}

		f1,_err := os.Open("file1.txt")
		defer f1.Close()

		f2, _ := os.Open("file2.txt")
		defer f2.Close()

		payload := io.MultiReader(f1, f2) // e.g., HTTP request POST  

		// Text if file does NOT exist; equivalent to Python's `if not os.path.exists(FILEpath)`:
		if _, err := os.Stat(FILEpath); os.IsNotExist(err) {
		  // FILEpath does not exist
		}
		// Test if file exists; equivalent to Python's `if os.path.exists(FILEpath)`:
		if _, err := os.Stat(FILEpath); err == nil {
		  // FILEpath exists
		}

		// Environment variable(s)
		os.Getenv(key)
		os.Setenv(key,val)
		os.Environ() // List all k-v pairs

		for _, ev := range os.Environ() {
			pair := strings.Split(ev, "=")
			fmt.Println(pair[0], pair[1]) // key, val
		}

		// Get path of self; the running binary 
		selfPath, _ := os.Getwd()
		// Other ways are UNRELIABLE ...
		selfPath, _ := filepath.Abs(filepath.Dir(os.Args[0]))
		// ... NOPE :: /c/TEMP/go-build825094783/b001/exe/build...
		selfPath, _ := os.Executable()
		// ... NOPE :: /c/TEMP/go-build825094783/b001/exe/build...

	// WRITE FILE :: APPEND|CREATE, Write-only (O_WRONLY); `|` is bitwise OR; 1|2 = 3
		f, err := os.OpenFile("data.file", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		defer f.Close() //... deferred until main() terminates  https://golang.org/pkg/os/#OpenFile

		d := "Some string."
		f.WriteString(d) // ... sans err chk
		if _, err = f.WriteString(" ... new data that wasn't there originally\n"); err != nil {
			panic(err)
		}
		f.WriteString("Append yet more.\n") // ... sans err chk

	// WRITE FILE :: Create
		nf, err := os.Create("index.html")
		if err != nil {
			log.Fatal("error creating file", err)
		}
		defer nf.Close()

		io.Copy(nf, strings.NewReader(str))

	import  "os/exec"  // 
	import "syscall"   // has issues; https://golang.org/pkg/syscall/#pkg-overview

		// Container  https://github.com/lizrice/containers-from-scratch/blob/master/main.go
		cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[2:]...)...)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.SysProcAttr = &syscall.SysProcAttr{  // has issues
			Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID | syscall.CLONE_NEWNS,
			Unshareflags: syscall.CLONE_NEWNS,
		}

		cmd.Run()

		// Execute/print `ls -al` command (@ Linux) ...
		x, err := exec.Command("ls", "-al").Output()
		fmt.Println(string(x[:])) // slice syntax `[:]` same as sans brackets; highlights that data type is slice

	import "time"  // https://golang.org/pkg/time/ 
	/*
	 	provides functionality for measuring and displaying time; calendrical calculations always assume a Gregorian calendar, with no leap seconds.
	 
		Operating Systems provide 2 clocks ...
			- WALL CLOCK; subject to changes for clock synchronization; for TELLING time.
			- MONOTONIC CLOCK; NOT subject to such changes; for MEASURING time. 

		`time.Now` returns `Time` STRUCT TYPE, which CONTAINS BOTH; later time-telling ops use the wall clock; later time-measuring ops use the monotonic clock.
	*/  
	// E.g., 
		x := 6 * time.Millisecond   // %v: 6ms, %T: time.Duration (NOT integer type)
		z(x)        
		func z(d time.Duration) { 
			time.Sleep(d)
		}

	import "flag"  // https://golang.org/pkg/flag/ 
		// Command-Line Flags  https://gobyexample.com/command-line-flags
		$ ./main.exe -flagName=flagVal arg1 arg2 ...
		// E.g., declare integer flag, `-flagname`, stored in the POINTER `ip`, of type `*int`.
		var ip = flag.Int("flagName", 1234, "help message for flagname")
		flag.Parse()  // to parse the command line into the previously defined flags. 
			// flags are then available as SLICE
				flag.Args()
			// or individually as 
				flag.Arg(i)

		fmt.Println(*ip)  // Note: use POINTER 
		// E.g., `gopl.io/ch2/echo4`; https://github.com/adonovan/gopl.io/blob/master/ch2/echo4/main.go

	// STRING MANIPULATION PACKAGEs  
		import "bytes"  // https://golang.org/pkg/bytes/  
			func Contains(b, subslice []byte) bool
			func Count(s, sep []byte) int
			func Fields(s []byte) [][]byte
			func HasPrefix(s, prefix []byte) bool
			func Index(s, sep []byte) int
			func Join(s [][]byte, sep []byte) []byte 

		import "strings"  // http://www.golangprograms.com/golang/string-functions/ 
			func Contains(s, substr string) bool
			func Count(s, sep string) int
			func Fields(s string) []string
			func HasPrefix(s, prefix string) bool
			func Index(s, sep string) int
			func Join(a []string, sep string) string 

		// return a new string; transformation applied to each char of original
			ToUpper, ToLower 

		// Map(func,string)
			func Map(mapping func(rune) rune, s string) string
			// E.g.,
				strings.Map(func(r rune) rune { return r + 1 }, "HAL-9000")  // IBM.:111

		import "unicode"  // https://golang.org/pkg/unicode/ 
			// Rune classifying functions:
			IsDigit, IsLetter, IsUpper, IsLower  // each takes one rune arg and returns a boolean 
			// Conversion functions: 
			ToUpper, ToLower                     // convert a rune if it is a letter.

		import "unicode/utf8"  // https://golang.org/pkg/unicode/utf8/ 
		func EncodeRune(p []byte, r rune) int         // ENCODE rune to bytes
		func DecodeRune(p []byte) (r rune, size int)  // DECODE bytes to rune 

			s := "Hi, ☧ \u754c" 
			// string size; bytes vs. runes
			fmt.Println("Bytes: ", len(s))                     // Bytes:  11  
			fmt.Println("Runes: ", utf8.RuneCountInString(s))  // Runes:  7  

			r := '☧' 
			// ENCODE rune to bytes 
			buf := make([]byte, 3)
			n := utf8.EncodeRune(buf, r)  // buf = [226 152 167] ; n = 3 

			c := string(buf[0:n])  // bytes to rune (character)
			fmt.Printf("%#U", []rune(c) )  //  [U+2627 '☧']  

			s := "Hi, ☧ \u754c" 
			// DECODE string to rune  
			for b := []byte(s); len(b) > 0; {
				r, size := utf8.DecodeRune(b) 
				fmt.Printf("%d  %#U\n", size, r)
				b = b[size:]
			}  
			/* 
				1  U+0048 'H'
				1  U+0069 'i'
				1  U+002C ','
				1  U+0020 ' '
				3  U+2627 '☧'
				1  U+0020 ' '
				3  U+754C '界' 
			*/ 

		import "strconv"  // https://golang.org/pkg/strconv/ 
		// for CONVERTING boolean, integer, and floating-point values TO and FROM their STRING representations, 
		// and functions for quoting and unquoting strings.
			n, err := strconv.Atoi(os.Args[1])  // convert 1st positional param (string) to integer 
			s := strconv.Itoa(-42)                            // -42 string 
			s := strconv.Quote(`"Foo's & Bar's Diner	☺"`)  // "\"Foo's & Bar's Diner\t☺\"" 
			q := QuoteToASCII("Hello, 世界")                  // "Hello, \u4e16\u754c"

		import "path"           // works with slash-delimited paths; appropriate for URLs, not for file names
		import "path/filepath"  // a set of functions for manipulating hierarchical names  

	import "gopkg.in/yaml.v2"  // YAML  https://github.com/go-yaml/yaml/tree/v2.2.2

	import "encoding/csv"   // read/parse/write CSV files	
		// Example CSV data inserted into template @ GoesToEleven  https://github.com/GoesToEleven/golang-web-dev/blob/master/012_hands-on/10_solution/main.go

		// SLICE to CSV
		    wr := csv.NewWriter(os.Stdout)
		    wr.Write([]string{"test1", "test2", "test3"})
		    wr.Flush()

	import "encoding/json"  // https://golang.org/pkg/encoding/json/  
		// All VALID JSON in golang must satisfy ... 
		map[string]interface{}  // JSON Object {"foo":1,"bar":"2","baz":[5,6,7]} 
		// or 
		[]interface{}  // JSON Array [1,"2",3]

		// An Encoder writes JSON values to an output stream.
		type Encoder struct {  
			// contains filtered or unexported fields
		}
		func NewEncoder(w io.Writer) *Encoder 

			// E.g., get a payload p := Payload{d}
			json.NewEncoder(w).Encode(p)

		// ENCODING 
		func Marshal(v interface{}) ([]byte, error)  // https://blog.golang.org/json-and-go  
			// Given the Go data structure, Message,
			type Message struct {
				Name string
				Body string
				Time int64
			}
			// and an instance of Message
			m := Message{"Alice", "Hello", 1294706395881547000}
			// we can marshal a JSON-encoded version of m using json.Marshal:
			b, err := json.Marshal(m)
			// If all is well, err will be nil and b will be a []byte containing this JSON data:
			b == []byte(`{"Name":"Alice","Body":"Hello","Time":1294706395881547000}`)

		// DECODING
		func Unmarshal(data []byte, v interface{}) error
			// We must first create a place where the decoded data will be stored
			var m Message
			// and call json.Unmarshal, passing it a []byte of JSON data and a pointer to m
			err := json.Unmarshal(b, &m) 
			// If b contains valid JSON and it SATISFIES (i.e., fits) the STRUCT m (TYPEs), then err is `nil` and ...
			m = Message{
				Name: "Alice",
				Body: "Hello",
				Time: 1294706395881547000,
			}

			// DECODE if JSON (b) is of UNKNOWN types  
			b := []byte(`{...}`)  // unknown values; may include array(s), and nested JSON too  
			var f interface{}     // EMPTY INTERFACE TYPE is generalized container

				var f []interface{} // Use if JSON Array   [1,"foo",3]
				var f interface{}   // Use if JSON Object  {"foo":1,"bar":"baz"}

			err := json.Unmarshal(b, &f)
			// ACCESS per type assertion against underlying map[string]interface{} of `f`:
			m := f.(map[string]interface{})
			for k, v := range m {
				switch vv := v.(type) {
				case string:
					fmt.Println(k, "is string", vv)
				case float64:
					fmt.Println(k, "is float64", vv)
				case []interface{}:
					fmt.Println(k, "is an array:")
					for i, u := range vv {
						fmt.Println(i, u)
					}
				default:
					fmt.Println(k, "is of a type I don't know how to handle")
				}
			}

	// REGULAR EXPRESSIONs
	import "regexp"  // RegExp  https://golang.org/pkg/regexp/ 
	// Show the syntax 
		go doc regexp/syntax 

		// MustCompile
		func MustCompile(str string) *Regexp
			// E.g., @ `/view/foo`, `m` is [/view/foo view foo]
				var validPath = regexp.MustCompile("^/(edit|save|view)/([a-zA-Z0-9]+)$")
				m := validPath.FindStringSubmatch(r.URL.Path)  // nil if no match
				errChk(m)  // handle nil here; terminate or whatever
				return m[2], nil  // 

	import "golang.org/x/net/html"  // HTML5-compliant tokenizer and parser. 
	// E.g., Parse HTML; GoPL ch.5  "gopl.io/ch5/findlinks2"
		// Parse returns parse tree of the HTML; input assumed UTF-8 encoded. 
		doc, err := html.Parse(resp.Body)  // from web 
		doc, err := html.Parse(os.Stdin)   // from FD 0 (/dev/stdin), e.g., `$./pkg < foo.html`
	
		// extract links per url
		for _, link := range visit(nil, doc) {  
			fmt.Println(link)
		}
		// visit appends to links each link found in n and returns the result.
		func visit(links []string, n *html.Node) []string {  
		    if n.Type == html.ElementNode && n.Data == "a" {
		        for _, a := range n.Attr {
		            if a.Key == "href" {
		                links = append(links, a.Val) 
		            }
		        }
		    }
		    for c := n.FirstChild; c != nil; c = c.NextSibling {
		        links = visit(links, c)        // recurse
		    }
		    return links  // note ubiquitous `links` param
		} 

	import "io"  // https://golang.org/pkg/io/ 
	// Golang "Reader" is what is READ FROM.  
	// Golang "Writer" is what is WRITTEN TO.

	// `io.Reader`, `io.Writer` and `net.Conn` are Golang's bread and butter of I/O composition

		io.Reader  // INTERFACE; wraps basic Read method, which reads up to `len(p)` bytes FROM slice `p`; Go Docs evermore confuse with "read into", which merely means the depth of the reading.
			type Reader interface { //
				Read(p []byte) (n int, err error)
			}
		io.Writer  // INTERFACE; wraps basic Write method, which writes `len(p)` bytes TO a data stream from slice `p`.
			type Writer interface { 
				Write(p []byte) (n int, err error)
			}
		// WRITE
			io.WriteString  // writes contents of `s` to `w`, which accepts `[]bytes`.
				func WriteString(w Writer, s string) (n int, err error)
				// e.g., 
					io.WriteString(os.Stdout, "Hello World")  //=> Hello World
					io.WriteString(conn, time.Now().Format("15:04:05\n"))  //=> 14:02:55 

			// Note that BOTH below are through `io.Writer` interface
				fmt.Fprintln(conn, "I dialed you. [written per fmt.Fprintln(w,str)]")
				io.WriteString(conn, "I dialed you. [written per io.WriteString(w,str)]")
			
		// READ & WRITE 
			io.Copy  // copies from `src` to `dst` until either `EOF` @ `src` or error.
				func Copy(dst Writer, src Reader) (written int64, err error) 

		// READ
			io.MultiReader  // returns `Reader`; logical concat of provided `readers`; read sequentially.
				func MultiReader(readers ...Reader) Reader 

			// +read per other packages
				ioutil.ReadAll, bufio.NewScanner, bufio.Scan, bufio.Text  

	import "io/ioutil"  // https://golang.org/pkg/io/ioutil/ 
		// READ :: FILE
		ioutil.ReadAll  // reads from `r` until an error or `EOF` and returns the data it read.
			func ReadAll(r io.Reader) ([]byte, error)  

			os.Stdin  // accept PIPEd input 
				piped, _ := ioutil.ReadAll(os.Stdin)  
				`$ seq  1 5 | ./pipe`  //=> "1\n2\n3\n4\n5\n"

				// parse an html file PIPEd to it
				doc, _ := html.Parse(os.Stdin) 
				`$ curl http://site.com | go run main.go`

			// TCP Listener 
			ln, _ := net.Listen("tcp", ":8080")
			defer ln.Close()
			for {
				conn, _ := ln.Accept()
			
				bs, _ := ioutil.ReadAll(conn) 

				fmt.Println(string(bs))    // Request 
				io.WriteString(c, "hello") // Response
				c.Close()
			}


			os.File  // E.g., from Rob Pike's `scrub.go`; removes meta from a JPG file 
			// https://github.com/robpike/scrub/blob/master/scrub.go 
				func scrub(f *os.File) {
					data, _ := ioutil.ReadAll(f)  
					s := NewScanner(data)  
					... 
				}
				// @ `main()` 
				file := flag.Arg(0)
				f, _ := os.Open(file)
				scrub(f)

		// READ FILE from local storage  https://tutorialedge.net/golang/reading-writing-files-in-go/  
		data, err := ioutil.ReadFile("localfile.data")
		fmt.Print(string(data)) // Print file contents
		
		// WRITE FILE to local storage
		d := []byte("All the data I wish to write to a file\n")
		err := ioutil.WriteFile("data.file", d, 0777)

	import "bufio"  // https://golang.org/pkg/bufio/ 
		type Scanner  // STRUCT  https://godoc.org/bufio#Scanner
		/*
			for reading data such as a file of newline-delimited lines of text. Successive calls to `Scan` method will step through the 'tokens' of a file, skipping the bytes between the tokens. Scanning stops unrecoverably at EOF, the first I/O error, or a token too large to fit in the buffer. 
		*/
		ScanBytes, ScanLines, ScanRunes, ScanWords, ReadWriter, NewReadWriter, Reader, NewReader, 
		ReadByte, ReadBytes, ReadLine, ReadRune, ReadSlice, ReadString, ...
		
		// SCANNER :: Read Line by Line
			// https://medium.com/golangspec/in-depth-introduction-to-bufio-scanner-in-golang-55483bb689b4
			bufio.NewScanner  // returns a new `Scanner` to read from `r`; defaults to `ScanLines`. 
				func NewScanner(r io.Reader) *Scanner 
			bufio.Scan  // advances the Scanner to the next token; avail. per `Bytes` or `Text` method.
				func (s *Scanner) Scan() bool
			bufio.Text  // returns the most recent token generated by a call to Scan
				func (s *Scanner) Text() string  

			// E.g., process text input
				input := "Now is the winter of our discontent,\nMade glorious summer by this sun of York.\n"
				scanner := bufio.NewScanner(strings.NewReader(input))
				// Set the SplitFunc to tokenize per word.
				scanner.Split(bufio.ScanWords)
				// Count the words.
				count := 0
				for scanner.Scan() {
				    count++
				}
				if err := scanner.Err(); err != nil {
				    fmt.Fprintln(os.Stderr, "reading input:", err)
				}
				fmt.Printf("%d\n", count)


			// E.g., process `net.Conn` request  https://github.com/GoesToEleven/golang-web-dev/blob/master/016_building-a-tcp-server-for-http/01/main.go
			func request(conn net.Conn) {
				i := 0
				scanner := bufio.NewScanner(conn)
				for scanner.Scan() {

					ln := scanner.Text() 
					fmt.Println(ln)
					fmt.Fprintf(conn, "%s\n", ln)  // to echo request back to client

					if i == 0 {
						// request line
						m := strings.Fields(ln)[0]  // Useful for parsing the request/status-line
						fmt.Println("***METHOD", m) 
					}

					if ln == "" {
						// headers are done
						break
					}
					i++
				}
			}

	import "net"  // https://golang.org/pkg/net/
	// for building client & server programs; comms over TCP, UDP, or Unix domain sockets
	// https://github.com/GoesToEleven/golang-web-dev/tree/master/015_understanding-TCP-servers 

		// @ SERVER
		net.Listener  // INTERFACE; a generic network listener for stream-oriented protocols.
		// METHODs  https://golang.org/pkg/net/#Listener
			Accept() (Conn, error)  // waits for and returns the next connection to the listener
			Close() error           // Close closes the listener.
			Addr() Addr             // returns the listener's network address.

			net.Listen  // FUNC; announces on the local network address. 
				func Listen(network, address string) (Listener, error) {/* body */}
				// E.g., 
				li, _ := net.Listen("tcp", ":8080") // returns `net.Listener` (interface type)
				defer li.Close()
				for {
					conn, _ := li.Accept()         // `Accept` is a `net.Listener` method
					go handle(conn)                // 1 goroutine per established connection
				}

				func handle(conn net.Conn) {       // handle the connection 
					defer conn.Close()
					request(conn)                  // read request
					respond(conn)                  // write response
				}  
				// REF: https://github.com/GoesToEleven/golang-web-dev/blob/master/016_building-a-tcp-server-for-http/01/main.go

				// Writing a response; header + body
					body := "CHECK OUT THE RESPONSE BODY PAYLOAD"
					io.WriteString(conn, "HTTP/1.1 200 OK\r\n")             // status line
					fmt.Fprintf(conn, "Content-Length: %d\r\n", len(body))  // header
					fmt.Fprint(conn, "Content-Type: text/plain\r\n")        // header
					io.WriteString(conn, "\r\n")                            // blank line; CRLF
					io.WriteString(conn, body)                              // body, aka, payload

		// @ CLIENT
		net.Conn  // INTERFACE; a generic stream-oriented network connection.
		// METHODs  https://golang.org/pkg/net/#Conn
	        Read(b []byte) (n int, err error)   // satisfies `io.Reader` interface
	        Write(b []byte) (n int, err error)  // satisfies `io.Writer` interface
	        Close() error
	        LocalAddr() Addr
	        RemoteAddr() Addr
	        SetDeadline(t time.Time) error
	        SetReadDeadline(t time.Time) error
	        SetWriteDeadline(t time.Time) error

			net.Dial    // FUNC; connects to the address on the named network
				func Dial(network, address string) (Conn, error)
				// E.g., dial & read response from server; write back to server
					conn, err := net.Dial("tcp", "localhost:8080")  // establish a TCP connection 
					defer conn.Close()
					fmt.Fprintln(conn, "I dialed you.")             // write to server per `io.Writer`
					bs, err := ioutil.ReadAll(conn)                 // read server response
					fmt.Println(string(bs))                         // write it to (client) STDOUT

		// READ|WRITE @ pkgs ... for SERVER|CLIENT 
			io.WriteString                                            // Write
			ioutil.ReadAll, bufio.NewScanner, bufio.Scan, bufio.Text  // Read 
			io.Copy                                                   // Read & Write  

	import "net/http"  // https://golang.org/pkg/net/http/
	// (TCP) HTTP SERVERs for client/server (request/response) implementations.
	// https://github.com/GoesToEleven/golang-web-dev/tree/master/017_understanding-net-http-package  
	
		// HANDLER
		http.Handler  // INTERFACE  https://godoc.org/net/http#Handler 
			// Any func implementing `ServeHTTP()` is Handler (interface type):
			type Handler interface { 
				ServeHTTP(ResponseWriter, *Request)  // METHOD of Handler interface
			}

			// RESPONSE WRITER 
			http.ResponseWriter  // INTERFACE  https://godoc.org/net/http#ResponseWriter 

			type ResponseWriter interface {
				Header() Header   // returns `Header` TYPE
				Write([]byte) (int, error)
				WriteHeader(int)
			}

				// RESPONSE HEADER; `Header()` METHOD returns `Header` TYPE
				http.Header  // METHOD of `ResponseWriter` interface  https://godoc.org/net/http#Header 
				type Header map[string][]string  // TYPE
				// Methods attached to `Header()` method of `ResponseWriter` interface
				func (h Header) Add(key, value string)
				func (h Header) Del(key string)
				func (h Header) Get(key string) string
				func (h Header) Set(key, value string)
				func (h Header) Write(w io.Writer) error
				func (h Header) WriteSubset(w io.Writer, exclude map[string]bool) error

				// E.g., SET a response header thus:
					w.Header().Set("Content-Type", "text/html; charset=utf-8")  // if HTML
					w.Header().Set("Content-Type", "application/json")          // if JSON

		// SERVER 
			http.ListenAndServe  // FUNC  https://godoc.org/net/http#ListenAndServe
			// ListenAndServe starts an HTTP server with a given address and handler. 
			func ListenAndServe(addr string, handler Handler) error 
				// E.g., @ shorthand for err := ...
					log.Fatal(http.ListenAndServe(":8080", nil))  

			//The `handler` is usually nil, which means to use `DefaultServeMux`. 
			// `Handle` and `HandleFunc` add handlers to `DefaultServeMux`: 
			type Handle 
				func Handle(pattern string, handler Handler)
			type HandleFunc 
				func HandleFunc(pattern string, handler func(ResponseWriter, *Request))

				// The `HandlerFunc` type is an adapter to allow the use of ordinary functions as HTTP handlers. If f is a function with the appropriate signature, HandlerFunc(f) is a Handler that calls f.
				func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request)

				// E.g., 
				http.Handle("/baz", bazhandler)      // Requires Handler type
				http.HandleFunc("/foo", fooHandler)  // Requires `handler func(ResponseWriter, *Request)`
				
				log.Fatal(http.ListenAndServe(":8080", nil))

				// Where, ...

				type hotdog int
				// Any func implementing `ServeHTTP()` is Handler (interface type):
				func (h hotdog) ServeHTTP(w http.ResponseWriter, r *http.Request) {
					io.WriteString(w, "hello from baz")
				}
				var bazhandler hotdog // implements ServeHTTP(), so is ALSO Handler (interface type)

				func fooHandler(w http.ResponseWriter, r *http.Request) {
					io.WriteString(w, "hello from foo")
				}


			// E.g., Simple static fileserver; listen & response only; 
				// `./public`, FS path is relative to PWD @ server-launch; FS path mapped to URL root, `/`
				http.Handle("/", http.FileServer(http.Dir("./public")))
				log.Fatal(http.ListenAndServe(":8080", nil)
				// or equivalently ...
				log.Fatal(http.ListenAndServe(":8080", http.FileServer(http.Dir("./public"))))

			// `HandlerFunc` TYPE is an adapter to allow use of ordinary functions as HTTP handlers
			http.HandlerFunc
				type HandlerFunc func(ResponseWriter, *Request)
				func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request)

				// E.g., define custom handler func 
					http.HandleFunc("/", fooHandler)   

					func fooHandler(w http.ResponseWriter, r *http.Request) {
						fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
						/*  process `r *http.Request` which is request from client */
					}

				// E.g., per custom method `m.ServeHTTP`; satisfies `Handler` interface 
				// https://github.com/GoesToEleven/golang-web-dev/blob/master/017_understanding-net-http-package/01_Handler/main.go
					type hotdog int  // dummy 

					func (m hotdog) ServeHTTP(w http.ResponseWriter, r *http.Request) {
						fmt.Fprintln(w, "Any code you want in this func")
					}
					
					func main() {
						var d hotdog
						http.ListenAndServe(":8080", d)
					}

			http.ServeMux  // STRUCT  https://godoc.org/net/http#ServeMux
			type ServeMux  // https://github.com/GoesToEleven/golang-web-dev/tree/master/018_understanding-net-http-ServeMux
				func NewServeMux() *ServeMux
				func (mux *ServeMux) Handle(pattern string, handler Handler)
				func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request))
				func (mux *ServeMux) Handler(r *Request) (h Handler, pattern string)
				func (mux *ServeMux) ServeHTTP(w ResponseWriter, r *Request)
	
				// E.g., replace case/switch with ServerMux pattern 
					// case/switch  https://github.com/GoesToEleven/golang-web-dev/blob/master/018_understanding-net-http-ServeMux/01_routing/main.go
					// ServerMux  https://github.com/GoesToEleven/golang-web-dev/blob/master/018_understanding-net-http-ServeMux/02_NewServeMux/main.go
					type hotdog int
					func (d hotdog) ServeHTTP(res http.ResponseWriter, req *http.Request) {
						io.WriteString(res, "dog dog dog")
					}
					...
					mux := http.NewServeMux()          // returns `*ServerMux`  
					mux.Handle("/dog", d)              // attach handle per route
					mux.Handle("/cat", c)
					http.ListenAndServe(":8080", mux)  //  specified handler; a `ServerMux`

					// SAME, per `DefaultServerMux` 
					http.Handle("/dog", d)
					http.Handle("/cat", c)
				
					http.ListenAndServe(":8080", nil)  // default handler; `DefaultServerMux`

					// SAME, per `HandleFunc`, which requires a particular function type input
					func d(res http.ResponseWriter, req *http.Request) {
						io.WriteString(res, "dog dog dog")
					}
					...
					http.HandleFunc("/dog", d)
					http.HandleFunc("/cat", c)
				
					http.ListenAndServe(":8080", nil)

					// SAME per `HandlerFunc`
					... // same as above
					http.Handle("/dog", http.HandlerFunc(d))
					http.Handle("/cat", http.HandlerFunc(c))
					... // same as above 

			// External ServerMux  (julienschmidt)
			httprouter  // https://godoc.org/github.com/julienschmidt/httprouter
			// A trie based high performance HTTP request router.
i				import "github.com/julienschmidt/httprouter" 

				// vendor it; clone from github (to wherever) ...
					$ git clone "https://github.com/julienschmidt/httprouter"
					// ... then copy to destination folder ...
					"/pkgRoot/vendor/github/julienschmidt/httprouter/..."
			
			// REQUEST 
			http.Request  // STRUCT  https://godoc.org/net/http#Request 
			// represents an HTTP request received by a server or to be sent by a client.
			// https://github.com/GoesToEleven/golang-web-dev/tree/master/017_understanding-net-http-package#request 
				type Request struct {
					Method string  // GET|POST|...
					URL *url.URL 
						//  Header = map[string][]string{
						//      "Accept-Encoding": {"gzip, deflate"},
						//      "Accept-Language": {"en-us"},
						//      "Foo": {"Bar", "two"},
						//  }
					Proto      string // "HTTP/1.0"; PROTOCOL 
					ProtoMajor int    // 1
					ProtoMinor int    // 0
					Header Header     // HTTP REQUEST HEADERs
					Body io.ReadCloser
					GetBody func() (io.ReadCloser, error)
					ContentLength int64
					TransferEncoding []string
					Close bool
					Host string
					Form url.Values      // only available after `ParseForm` is called
					PostForm url.Values  // only available after `ParseForm` is called
					MultipartForm *multipart.Form
					Trailer Header
					RemoteAddr string  // network address that sent the request; for logging
					RequestURI string
					TLS *tls.ConnectionState
					Cancel <-chan struct{}
					Response *Response
				}

				// FUNCtions RETURNing `*Request` TYPE
					func NewRequest(method, url string, body io.Reader) (*Request, error)
					func ReadRequest(b *bufio.Reader) (*Request, error)
					/*
						`NewRequest` returns a Request suitable for use with `Client.Do` or `Transport.RoundTrip`. To create a rquest for use with testing a Server Handler, either use the `NewRequest` function in the `net/http/httptest` package, use `ReadRequest`, or manually update the `Request` fields. See the `Request` type's documentation for the difference between inbound and outbound request fields.  
						https://godoc.org/net/http#NewRequest
					*/

					http.NewRequest(method, url, body)
					// E.g.,
						resp, err := http.Get("http://example.com/")
						if err != nil {
							// handle error; ALSO, some say put `defer res.Body.Close()` stmt here
						}
						defer resp.Body.Close()  // Client MUST CLOSE the response body
						body, err := ioutil.ReadAll(resp.Body)

					// E.g., upload data, `payload`, per POST
						req, _ := http.NewRequest("POST", "https://example.com/upload", payload)
						// `Set` or `Add` custom HTTP-header 
						req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
						req.Header.Add("If-None-Match", `W/"wyzzy"`)
						// send request
						res, _ := http.DefaultClient.Do(req)
						defer res.Body.Close()

					// E.g., upload JSON `data`, a `Payload` struct, per POST
						// per curl 
						curl -X POST -H "Content-Type: application/json" \
							-H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" \
							-d '{"type":"A","name":"www","data":"162.10.66.0","priority":null,"port":null,"weight":null}' \ "https://api.digitalocean.com/v2/domains/example.com/records"

						// Golang equiv. Generated by curl-to-Go: https://mholt.github.io/curl-to-go
						type Payload struct {  //  https://blog.golang.org/json-and-go 
							Type     string      `json:"type"`
							Name     string      `json:"name"`
							Data     string      `json:"data"`
							Priority interface{} `json:"priority"`
							Port     interface{} `json:"port"`
							Weight   interface{} `json:"weight"`
						}

						data := Payload{
							"type":"A","name":"www","data":"162.10.66.0","priority":null,"port":null,"weight":null
						}
						payloadBytes, _ := json.Marshal(data)
						body := bytes.NewReader(payloadBytes)
						// if want to send string instead
						body := strings.NewReader(` Hello from server @ localhost:8080`)

						req, _ := http.NewRequest("POST", "https://api.digitalocean.com/v2/domains/example.com/records", body)

						req.Header.Set("Content-Type", "application/json")
						req.Header.Set("Authorization", "Bearer b7d03a6947b217efb6f3ec3bd3504582")

						res, _ := http.DefaultClient.Do(req)
						defer res.Body.Close()

				// METHODs of `*Request` TYPE receiver
					func (r *Request) AddCookie(c *Cookie)
					func (r *Request) BasicAuth() (username, password string, ok bool)
					func (r *Request) Context() context.Context
					func (r *Request) Cookie(name string) (*Cookie, error)
					func (r *Request) Cookies() []*Cookie
					func (r *Request) FormFile(key string) (multipart.File, *multipart.FileHeader, error)
					func (r *Request) FormValue(key string) string
					func (r *Request) MultipartReader() (*multipart.Reader, error)
					func (r *Request) ParseForm() error
					func (r *Request) ParseMultipartForm(maxMemory int64) error
					func (r *Request) PostFormValue(key string) string
					func (r *Request) ProtoAtLeast(major, minor int) bool
					func (r *Request) Referer() string
					func (r *Request) SetBasicAuth(username, password string)
					func (r *Request) UserAgent() string
					func (r *Request) WithContext(ctx context.Context) *Request
					func (r *Request) Write(w io.Writer) error
					func (r *Request) WriteProxy(w io.Writer) error 

					// e.g., 
						r, err := http.NewRequest("GET", "http://example.com", nil)

					// e.g., process `r *http.Request`
						// Headers 
						for k, v := range r.Header {fmt.Sprintf(w, "%q:%q\n", k, v)}

				// `ParseForm()`  https://golang.org/pkg/net/http/#Request.ParseForm
					func (r *Request) ParseForm() error {...}

					r.ParseForm()  

					// Query string, `?key1=val1&key1=val2,val3;key2=val4`, PARSED
						for k, v := range r.Form {fmt.Sprintf(w, "Form[%q] = %q\n", k, v)}
						
				// URL values
					type URL struct {        // https://golang.org/pkg/net/url/#URL
						Scheme     string
						Opaque     string    // encoded opaque data
						User       *Userinfo // username and password information
						Host       string    // host or host:port
						Path       string    // path (relative paths may omit leading slash)
						RawPath    string    // encoded path hint (see EscapedPath method)
						ForceQuery bool      // append a query ('?') even if RawQuery is empty
						RawQuery   string    // encoded query values, without '?'
						Fragment   string    // fragment for references, without '#'; NOT passed by client
					}

			// SERVER 
				http.Server  // STRUCT  https://godoc.org/net/http#Server
				// control over the server's behavior
				s := &http.Server{
							Addr:           ":8080",
							Handler:        myHandler,
							ReadTimeout:    10 * time.Second,
							WriteTimeout:   10 * time.Second,
							MaxHeaderBytes: 1 << 20,
						}
						log.Fatal(s.ListenAndServe())

			// CLIENT  
				http.Client  // STRUCT https://godoc.org/net/http#Client
				type Client struct {
					Transport RoundTripper
					CheckRedirect func(req *Request, via []*Request) error
					Jar CookieJar
					Timeout time.Duration
				}
				// METHODs on `*http.Client` TYPE
					func (c *Client) Do(req *Request) (*Response, error)
					func (c *Client) Get(url string) (resp *Response, err error)
					func (c *Client) Head(url string) (resp *Response, err error)
					func (c *Client) Post(url string, contentType string, body io.Reader) (resp *Response, err error)
					func (c *Client) PostForm(url string, data url.Values) (resp *Response, err error)
			

				// `DefaultClient` is the default `http.Client`; used by Get, Head, and Post  
					// https://medium.com/@nate510/don-t-use-go-s-default-http-client-4804cb19f779  
					// var DefaultClient = &Client{} // timeout `0` (no timeout; forever)  
					// Define a CUSTOM `http.Client` with a sensible timeout  
					var netClient = &http.Client{
						Timeout: time.Second * 10,
					}
					res, _ := netClient.Get(url)

				// Create a custom client; control over HTTP client headers, redirect policy, and other settings
					client := &http.Client{
						CheckRedirect: redirectPolicyFunc,
					}
					resp, err := client.Get("http://example.com")
					// ...
					req, err := http.NewRequest("GET", "http://example.com", nil)
					// ...
					req.Header.Add("If-None-Match", `W/"wyzzy"`)
					resp, err := client.Do(req)
					// ...

			// TRANSPORT 
				http.Transport  // STRUCT  https://godoc.org/net/http#Transport 
				// Control @ proxies, TLS configuration, keep-alives, compression, etc.  
				type Transport struct {
				    Proxy func(*Request) (*url.URL, error)
				    DialContext func(ctx context.Context, network, addr string) (net.Conn, error)
				    DialTLS func(network, addr string) (net.Conn, error)
				    TLSClientConfig *tls.Config
				    TLSHandshakeTimeout time.Duration
				    DisableKeepAlives bool
				    DisableCompression bool
				    MaxIdleConns int
				    MaxIdleConnsPerHost int
				    IdleConnTimeout time.Duration
				    ResponseHeaderTimeout time.Duration
				    ExpectContinueTimeout time.Duration
				    TLSNextProto map[string]func(authority string, c *tls.Conn) RoundTripper
				    ProxyConnectHeader Header
				    MaxResponseHeaderBytes int64
				}
				// METHODS on `*http.Transport` TYPE
					func (t *Transport) CancelRequest(req *Request)
					func (t *Transport) CloseIdleConnections()
					func (t *Transport) RegisterProtocol(scheme string, rt RoundTripper)
					func (t *Transport) RoundTrip(req *Request) (*Response, error)
				
					// E.g., 
						tr := &http.Transport{
							MaxIdleConns:       10,
							IdleConnTimeout:    30 * time.Second,
							DisableCompression: true,
						}
						client := &http.Client{Transport: tr}
						resp, err := client.Get("https://example.com")

			// RESPONSE (from `http.Client` & `http.Transport`)
			http.Response  // STRUCT  https://godoc.org/net/http#Response 
			type Response struct {
				Status     string // e.g. "200 OK"
				StatusCode int    // e.g. 200
				Proto      string // e.g. "HTTP/1.0"
				ProtoMajor int    // e.g. 1
				ProtoMinor int    // e.g. 0
				Header Header
				Body io.ReadCloser
				ContentLength int64
				TransferEncoding []string
				Close bool
				Uncompressed bool
				Trailer Header
				Request *Request
				TLS *tls.ConnectionState
			}
			func Get(url string) (resp *Response, err error)
			func Head(url string) (resp *Response, err error)
			func Post(url string, contentType string, body io.Reader) (resp *Response, err error)
			func PostForm(url string, data url.Values) (resp *Response, err error)
			func ReadResponse(r *bufio.Reader, req *Request) (*Response, error)

			func (r *Response) Cookies() []*Cookie
			func (r *Response) Location() (*url.URL, error)
			func (r *Response) ProtoAtLeast(major, minor int) bool
			func (r *Response) Write(w io.Writer) error

				// e.g., 
				resp, err := http.Get("http://example.com/")
				resp, err := http.Post("http://example.com/upload", "image/jpeg", &buf)
				resp, err := http.PostForm("http://example.com/form", url.Values{"key": {"Value"}, "id": {"123"}})


		// SERVING FILEs 
		func ServeContent(w ResponseWriter, req *Request, name string, modtime time.Time, content io.ReadSeeker)
		http.ServeContent  // https://godoc.org/net/http#ServeContent
			/*
			`ServeContent` replies to the request using the content in the provided ReadSeeker. 
			
			The main BENEFIT of `ServeContent` over `io.Copy` is that it handles Range requests properly, sets the MIME type, and handles If-Match, If-Unmodified-Since, If-None-Match, If-Modified-Since, and If-Range requests.
			Note that `*os.File` implements the `io.ReadSeeker` interface. 
			*/ // E.g., 
			f, err := os.Open("toby.jpg")
			if err != nil {
				http.Error(w, "file not found", 404)
				return
			}
			defer f.Close()

			io.Copy(w, f)
			// or
			http.ServeContent(w, req, f.Name(), fi.ModTime(), f)

		// Sans "os" package; integral File Handling:
		http.ServeFile  // https://godoc.org/net/http#ServeFile 
		func ServeFile(w ResponseWriter, r *Request, name string)  
		func FileServer(root FileSystem) Handler  
		func StripPrefix(prefix string, h Handler) Handler

		// E.g., 
			http.ServeFile(w, req, "toby.jpg")
			// or 
			http.Handle("/", http.FileServer(http.Dir(".")))  // lists all files @ root
			// or , to remap static requested routes to the actual dynamic routes ...
			http.Handle("/resources/", http.StripPrefix("/resources", http.FileServer(http.Dir("./assets")))
			// So, STATIC @ `<img src="/resources/pics/dog2.jpeg">` is SERVED from `/assets/pics/dog2.jpg` 
			// I.e., requested per `http://localhost:8080/resources/pics/dog2.jpeg`
			
	import "html/template"  // https://golang.org/pkg/html/template/ 
	// TEMPLATEs [.tmpl] [.gohtml]; TEXT and HTML 
	/*
		A string or file containing one or more ACTIONS; portions enclosed in DOUBLE BRACES, `{{...}}`; each action contains an EXPRESSION in the TEMPLATE LANGUAGE NOTATION; can print values, select struct fields, call functions/methods, express flow-control such as if-else statements and range loops, etc.
	*/

		type Template struct {
			// The underlying template's parse tree, updated to be HTML-safe.
			Tree *parse.Tree
			// contains filtered or unexported fields
		}
		// a `Template` METHOD  https://github.com/GoesToEleven/golang-web-dev/tree/master/004_parse_execute 
		func (t *Template) ExecuteTemplate(wr io.Writer, name string, data interface{}) error

		// E.g., Process & serve template file for HTTP-server (request/response) https://github.com/GoesToEleven/golang-web-dev/blob/master/017_understanding-net-http-package/03_Request/03_URL/main.go  

			data := struct {  // data per STRUCT LITERAL
				Method      string
				Submissions url.Values
			}{
				req.Method,
				req.Form,
			}
			var tpl *template.Template

			func init() {  // PERFORMANT PARSING; CACHEing
				tpl = template.Must(template.ParseGlob("templates/*"))
			}
			
			tpl.ExecuteTemplate(w, "index.gohtml", data)

		// PREDEFINED GLOBAL FUNCTIONs  https://godoc.org/text/template#hdr-Functions

		// PARSE / EXECUTE  https://github.com/GoesToEleven/golang-web-dev/tree/master/004_parse_execute
		// E.g., template string examples
			const templateStr = `	
			<div id="foo">
				{{block "content" .}}
				<div id="content">
					{{.Body}}
				</div
				<ul>
					{{- range .Links}}
					<li><a href="{{.URL}}">{{.Title}}</a></li>
					{{- end}}
				</ul>
			</div>
			`
			// The piece (below) from `{{if .}}` to `{{end}}` executes only if the value of the current data item, `.` (dot), is non-empty.
			const templateStr = `
			<html>
			...
			{{if .}}
			...
			{{.}}
			...
			{{end}}
			...
			</html>
			`

	import "sync"  // https://golang.org/pkg/sync/
	// basic synchronization primitives such as mutual exclusion locks.
		sync.WaitGroup  // A special counter; `WaitGroup` waits for a collection of goroutines to finish. The main goroutine calls `Add()` to set the number of goroutines to wait for. Then each of the goroutines runs and calls `Done()` when finished. At the same time, Wait can be used to block until all goroutines have finished.  https://golang.org/pkg/sync/#WaitGroup
		type WaitGroup struct {
			// contains filtered or unexported fields
		}
		// `Add()` and `Done()`  method signatures
		func (wg *WaitGroup) Add(delta int)  // adds delta is WaitGroup counter, i.e., the number of goroutines to wait on (unless the counter was not zero).
		func (wg *WaitGroup) Done()  // decrements the WaitGroup counter.
		// E.g.,
			var wg sync.WaitGroup

			func main() {
				wg.Add(2)  // increment WaitGrop counter by the number of goroutines
				go func() { foo(); wg.Done(); }        // decrement counter
				go func() { defer wg.Done() ; bar(); } // decrement counter AFTER goroutine; better
				wg.Wait()  // block until WaitGroup counter is zero.
			}

		sync.Mutex  // MUTEX; Mutual Exclusion (Lock); data structure that ensures only one goroutine can access a variable at a time; avoid conflicts, sans communication (channels).  https://golang.org/pkg/sync/#Mutex   https://tour.golang.org/concurrency/9
		// 2 methods: Lock, Unlock
			var wg sync.WaitGroup
			var counter int
			var mutex sync.Mutex

			func main() {
				wg.Add(2)
				go incrementor("Foo:")
				go incrementor("Bar:")
				wg.Wait()
			}

			func incrementor(s string) {
				rand.Seed(time.Now().UnixNano())
				for i := 0; i < 20; i++ {
					time.Sleep(time.Duration(rand.Intn(20)) * time.Millisecond)
					mutex.Lock()
					counter++
					fmt.Println(s, i, "Counter:", counter)
					mutex.Unlock()
				}
				wg.Done()
			}

			import "sync/atomic"  //  https://golang.org/pkg/sync/atomic/
			// low-level ATOMIC MEMORY PRIMITIVES useful for implementing synchronization algorithms. These functions require great care to be used correctly. Except for special, low-level applications, synchronization is better done with channels or the facilities of the sync package.

			AddInt64 // atomically adds delta to *addr and returns the new value.
			func AddInt64(addr *int64, delta int64) (new int64) // signature
				// E.g., replace Mutex Lock/Unlock @ `counter++`, in above example, with atomic counter
				atomic.AddInt64(&counter, 1)

		sync.Once  // an object that will perform exactly one action.
			type Once struct {
				// contains filtered or unexported fields
			}
			// `Do` method signatures
			func (*Once) Do
			func (o *Once) Do(f func())
			// E.g.,
				var once sync.Once
				...
				done := make(chan bool)
				for i := 0; i < 10; i++ {
					go func() {
						once.Do(onceBody)  // executes only once
						done <- true
					}()
				}

	import "runtime"  // https://golang.org/pkg/runtime/
	// operations that interact with Go's runtime system, such as functions to control goroutines.
		// E.g., set max # CPUs running simultaneously,`GOMAXPROCS`, to # available, `NumCPU`
			runtime.GOMAXPROCS(runtime.NumCPU())

	import "crypto/rand"  // https://golang.org/pkg/crypto/rand/ 
	// cryptographically secure pseudorandom number generator 

		// Read 10 numbers from `rand.Reader`; write them to byte slice `b`. 
		b := make([]byte, 10)  
		_, err := rand.Read(b)
		if err != nil {
			fmt.Println("error:", err)
			return
		}
		// The slice should now contain random bytes instead of only zeroes.
		fmt.Println(bytes.Equal(b, make([]byte, c))) 

	import "math/rand"  // https://golang.org/pkg/math/rand/#pkg-overview 
	import "time"       // https://golang.org/pkg/time/#example_Time_Unix
		time.Now().Format("15:04:05\n")  // formats by example !
		
		func main() {  // pseudorandom generators :: integer & string 
			rand.Seed(time.Now().UTC().UnixNano())  // 1257894000000000000
			fmt.Println(randInt(1,100))             // 48
			fmt.Println(randomString(10))           // DCMNOYCNJH
		}

		func randInt(min int, max int) int {
			return min + rand.Intn(max-min)
		}

		func randomString(l int) string {
			bytes := make([]byte, l)
			for i := 0; i < l; i++ {
				bytes[i] = byte(randInt(65, 90))  // https://en.wikipedia.org/wiki/ASCII
			}
			return string(bytes)
		}
	