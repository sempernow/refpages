[ { x: "foo" }, { x: "bar"} ].reduce( (acc,curr) => {acc.x += curr.x+'\n'; return acc},{x:''} )
// { x: 'foo\nbar\n' }

// add missing key(s)
var x = [ { h: "scud" }, { x: "bar"} ]
x.map(el => { return el.hasOwnProperty('x') ? el : el['x'] = 'x'; })
// [ 'x', { x: 'bar' } ]
x
// [ { h: 'scud', x: 'x' }, { x: 'bar' } ]


// ====================
/*
https://atendesigngroup.com/blog/array-map-filter-and-reduce-js  
Array.reduce()
to compute a single value by iterating over a list of items. 
*/

// Signature:
Array.prototype.reduce(callback(previousValue, currentValue[, index], array]), initialValue) 
// per MDN https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce 
            arr.reduce(callback(accumulator, currentValue[, index[, array]]), [, initialValue]) 
/*
The reduce callback takes at least two arguments. The first is the previous value returned from the last iteration. The second is the current value being iterated over in the array. The return value gets passed on as the 1st argument in the next iteration. The return value of the initial reduce call will be the return value from the callback on the final iteration (FIFO?); fed to the accumulator.
*/
// E.g., 
// Given an array of, "constructicons" (below), Construction Transformers,   
// assemble/combine them into one giant robot called Devastator.

function assemble(combiner, transformer) {
    // On each iteration, add the current transformer to the form object of the combiner.
    combiner.form[transformer.bodyPart] = transformer.name;
    return combiner;
}

// Asemble Constructicons into Devastator:
var devastator = constructicons.reduce(assemble, 
    {
        name: 'Devastator',
        team: 'Decepticon',
        form: {}
    }
);

// NOTE choice for 'combiner'; a hollow "struct" (initial value)   
// to be filled during iterative calls to "assemble", the callback at reduce().  
/*
devastator == {
    name: 'Devastator',
    team: 'Decepticon',
    form: {
        leftArm: "Bonecrusher"
        leftLeg: "Mixmaster"
        lowerTorso: "Long Haul"
        rightArm: "Scavenger"
        rightLeg: "Scrapper"
        upperTorso: "Hook"
    }
}
*/

/*
When we call reduce on the array; the first argument is the callback; the second is the initial value passed that callback on the first iteration. In the below example begin with a new Transformer with just the name and team values set. On each iteration of assemble, we add a Constructicon to the form property, until it is fully assembled.
*/
var constructicons = [{
        name: 'Scrapper',
        form: 'Freightliner Truck',
        team: 'Decepticon',
        bodyPart: 'rightLeg'
    },
    {
        name: 'Hook',
        form: 'Mobile Crane',
        team: 'Decepticon',
        bodyPart: 'upperTorso'
    },
    {
        name: 'Bonecrusher',
        form: 'Bulldozer',
        team: 'Decepticon',
        bodyPart: 'leftArm'
    },
    {
        name: 'Scavenger',
        form: 'Excavator',
        team: 'Decepticon',
        bodyPart: 'rightArm'
    },
    {
        name: 'Mixmaster',
        form: 'Concrete Mixer',
        team: 'Decepticon',
        bodyPart: 'leftLeg'
    },
    {
        name: 'Long Haul',
        form: 'Dump Truck',
        team: 'Decepticon',
        bodyPart: 'lowerTorso'
    }
];