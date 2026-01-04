package main 
// TYPE SWITCH "style" of Interfaces  https://notes.shichao.io/gopl/ch7/#type-switches
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

// https://notes.shichao.io/gopl/ch7/#type-switches
// https://github.com/shichao-an/notes/blob/master/docs/gopl/ch7.md
func sqlQuote(x interface{}) string {
	switch x := x.(type) {
	case nil:
		return "NULL"
	case int, uint:
		return fmt.Sprintf("%d", x) // x has type interface{} here.
	case bool:
		if x {
			return "TRUE"
		}
		return "FALSE"
	case string:
		return sqlQuoteString(x) // (not shown)
	default:
		panic(fmt.Sprintf("unexpected type %T: %v", x, x))
	}
}
