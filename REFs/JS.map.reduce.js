
// @ Map  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map#Syntax
Array.prototype.map()
    arr.map(callback(currentVal, index, arr), thisVal)
    arr.map(callback(currentVal[, index[, arr]]), [, thisArg])

    arr.map((i) => perFn(i)).join('')
    // Simplified (implicit) syntax
    arr.map(perFn).join('')  

    arr = ['foo','bar']
    arr.map(console.log)       // currentValue, index, arr
    // foo 0 [ 'foo', 'bar' ]  // currentValue, index, arr
    // bar 1 [ 'foo', 'bar' ]  // currentValue, index, arr

    arr.map(x => console.log(x))
    // foo
    // bar

    // Both cases, same effect as ...
    arr.forEach(console.log)

// @ Reduce  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce#Syntax
Array.prototype.reduce()
    arr.reduce(callback(total, currentVal, index, arr), initialVal)
    arr.reduce(callback(accum, currentVal[, index[, arr]]), [, initialVal])

    arr.reduce((acc, nth) => perFn(acc, nth), '')
    // Simplified (implicit) syntax
    arr.reduce(perFn, '')
    
    // NOTE: Set an initialVal, e.g., "''", else 1st el of source-array will be used (at 1st iter of acc).

// Convert string to array, per letter 
    ;[...'per letter']       // [ 'p', 'e', 'r', ' ', 'l', 'e', 't', 't', 'e', 'r' ]

// Extract OBJ KEYS to ARRAY
    Object.keys({a:1,b:2})   // [ a, b ]

// Extract OBJ VALUES to ARRAY
    Object.values({a:1,b:2}) // [ 1, 2 ]

    // ... then use .map() on any of the above

// ============================================================================
//  EXAMPLES 
// ============================================================================

// Flatten ARRAY of k:v pairs (objects) to an OBJECT of those pairs.
arr = [{a:11} , {x:99}]
arr.reduce((acc, o) => {
        const k = Object.keys(o)[0]  // 1st key
        acc[k] = o[k]
        return acc 
    }, {})
//=> {a: 11, x: 99}

// Transform array to object
a = [ 'foo', 'bar' ]
g = (acc, el, i) => ((acc[el] = 3*i), acc)
a.reduce(g, {}) // { foo: 0, bar: 3 }

//... same, but els are HTML nodes
a = [display, handle, foo]
g = (acc,el) => ((acc[el.name] = {min: +(el.min || el.minLength)}), acc)
a.reduce(g, {})
/** ==>
    <form action="">
        <input type="text" name="display" minlength="33" required>
        <input type="text" name="handle" min="17" required>
        <input type="text" name="foo" pattern="[aA-zZ,1-9]{3,11}" required>
    </form>

    {
        "display": {
            "min": 33
        },
        "handle": {
            "min": 17
        },
        "foo": {
            "min": -1
        }
    }
**/

// Sort ARRAY of OBJECTS (`list`) by a specific key ("date")
//... doesn't require any map/reduce/filter, but placed here because it is a common mapping.
list.sort((a, b) => {return a.date - b.date})   //... sorts IN PLACE.
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort

console.log("sorted:", list.map(el => el.date)) // [<date1>, <date2>, ...]

// Generate/fill a template for a list of data from an array
// sans React; React version @  https://scotch.io/tutorials/4-uses-of-javascripts-arraymap-you-should-know  

    const names = ["john", "sean", "mike", "jean", "chris"]

    var namesList = () => { 
        return `<div><ol>
                    ${names.map( name => `<li key="${name}"> ${name} </li>`).join('')}&vellip;
                </ol></div>` 
    }

// Fill a template with data, as many instances as there is data.
    // The data is parsed JSON; an array of object instances
    a = [{head: "...", body: "...", f1:55, ..}, {head: ..}, ..]

    // @ Map
    function template(j) {
        return `\n<h2 class="foo"><code>${j.head}</code></h2>\n<p>${j.body}</p>\n<div><span>${j.f1}</span> ${j.f2} <i>${j.f3}</i> <span>${j.f4}</span></div>\n`
    }
    x = a.map((v) => template(v)).join('') 
    // Simplified (implicit) syntax
    x = a.map(template).join('')  

    // @ Reduce
    function concat(s, j) {
        return s + template(j)
    }
    x = a.reduce((acc,itr) => concat(acc,itr),'')
    // Simplified (implicit) syntax
    x = a.reduce(concat,'')  

// As iterator ::  map() vs forEach() :: map handles function return FASTER.
// https://codeburst.io/javascript-map-vs-foreach-f38111822c0f  
    a.map((_,i) => perItr(i))
    a.forEach((_,i) => perItr(i))

    // Both take params (value, index)

// map() @ https://www.robinwieruch.de/javascript-map-array/   

    // Extract values per key (Array of Objects)
    const arrOfObjs = [
        { a: 1, b: 'first' },
        { a: 2, b: 'second' },
        { a: 3, b: 'third' },
      ]
    x = arrOfObjs.map(obj => obj.b)
    // ['first', 'second', 'third']

    // Reverse an array
    const a = [1, 2, 3, 4, 5]
    a.map(n => n * 2).reverse()
    // [2, 4, 6, 8, 10]

    // Process a TWO-DIMENSIONAL array
    const a = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];
    x = a.map(v => v.map(n => n * 2));
    // [[2, 4, 6], [8, 10, 12], [14, 16, 18]]

// map(), reduce(), filter()  
// @ https://www.freecodecamp.org/news/15-useful-javascript-examples-of-map-reduce-and-filter-74cbbb5e0a1f/

    // Reduce :: flatten an array of arrays
    x = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    x.reduce((acc, it) => [...acc, ...it], [])
    // [1, 2, 3, 4, 5, 6, 7, 8, 9]

    // Reduce :: Operate on array of objects
    var users
    users = [
        { id: 11, name: 'Adam', age: 23, group: 'editor' },
        { id: 47, name: 'John', age: 28, group: 'admin' },
        { id: 85, name: 'William', age: 34, group: 'editor' },
        { id: 97, name: 'Oliver', age: 28, group: 'admin' }
    ]

    // Reduce :: Value frequencies of a target-key 
    users.reduce((acc, it) => {
        acc[it.age] = acc[it.age] + 1 || 1
        return acc
    }, {})
    // {23: 1, 28: 2, 34: 1}

    // Reduce :: Create an index (lookup table) on an array of objects
    x = users.reduce((acc, it) => (acc[it.id] = it, acc), {})
    // {
    //   11: { id: 11, name: 'Adam', age: 23, group: 'editor' },
    //   47: { id: 47, name: 'John', age: 28, group: 'admin' },
    //   85: { id: 85, name: 'William', age: 34, group: 'editor' },
    //   97: { id: 97, name: 'Oliver', age: 28, group: 'admin' }
    // }
    x[85].name  // fast

    // Reduce :: Extract UNIQUE values for specific key
    x = [...new Set(users.map(it => it.group))]
    // ['editor', 'admin']

    // Reduce :: Object key-value map reversal
    const cities = {
      Lyon: 'France',
      Berlin: 'Germany',
      Paris: 'France'
    }
    // Using Comma Operator  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Comma_Operator 
    var countries
    countries = Object.keys(cities).reduce(
      (acc, k) => (acc[cities[k]] = [...(acc[cities[k]] || []), k], acc) , {})
    // ... is identical to ... 
    countries = Object.keys(cities).reduce((acc, k) => {
        let country = cities[k]
        acc[country] = acc[country] || []
        acc[country].push(k)
        return acc
    }, {})
    // countries is
    // {
    //   France: ["Lyon", "Paris"],
    //   Germany: ["Berlin"]
    // }

    // Map :: Celcius to Farenheit 
    x = [-15, -5, 0, 10, 16, 20, 24, 32]
    x.map(t => t * 1.8 + 32)
    // [5, 23, 32, 50, 60.8, 68, 75.2, 89.6]

    // Map :: Encode an object into a query string
    x = {lat: 45, lng: 6, alt: 1000}
    Object.entries(x)
    // [ [ 'lat', 45 ], [ 'lng', 6 ], [ 'alt', 1000 ] ]
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/entries  
    Object.entries(x).map(p => p[0] + '=' + p[1]).join('&')
    // "lat=45&lng=6&alt=1000"
    // ... but to ensure URL-encoded ...
    Object.entries(x).map(p => encodeURIComponent(p[0]) + '=' + encodeURIComponent(p[1])).join('&')

    // Map :: array of objects, per selected keys, as a string
    users.map(({id, age, group}) => `\n${id} ${age} ${group}`).join('')
    // "
    // 11 23 editor
    // 47 28 admin
    // 85 34 editor
    // 97 28 admin"  // JSON.stringify can do, but not as a table:
    JSON.stringify(users, ['id', 'name', 'group'], 2);

    // Map :: Find and replace a key-value pair in an array of objects
    // (If index is known, then simply `users[index].age = 29`.)
    const updated = users.map(p => p.id !== 47 ? p : {...p, age: p.age + 1})  // Edge reports error here; @ `...p`
    // ... { ..., name: 'John', age: 29, ... }, ...
    // Instead of changing  single item in array, create new one with only one element different.

    // Map :: Union (A ∪ B) of arrays
    var arrA, arrB
    arrA = [1, 4, 3, 2]
    arrB = [5, 2, 6, 7, 1]
    x = [...new Set([...arrA, ...arrB])]
    // [1, 4, 3, 2, 5, 6, 7]

    // Map :: Intersection (A ∩ B) of arrays
    arrA = [1, 4, 3, 2]
    arrB = [5, 2, 6, 7, 1]
    arrA.filter(it => arrB.includes(it))
    // [1, 2]


// Filter out duplicates; make UNIQUE array, but O(n^2)
    a = [7,2,1,7,1,1]
    a.filter((v, i, arr) => arr.indexOf(v) === i)
    [ 7, 2, 1 ]