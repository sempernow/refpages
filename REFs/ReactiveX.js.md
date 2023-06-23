# [RxJS](http://reactivex.io/rxjs/ "ReactiveX.io") | [ReactiveX](https://en.wikipedia.org/wiki/Reactive_extensions "Reactive Extensions @ Wikipedia") | @ [GitHub](https://github.com/ReactiveX/rxjs "GitHub") 
>RxJS is a (__Microsoft__) library for composing asynchronous and event-based programs by using observable sequences. It provides one core type, the Observable, satellite types (Observer, Schedulers, Subjects) and operators (map, filter, reduce, every, etc) to allow handling asynchronous events as collections.

> Think of RxJS as Lodash for events.

> ReactiveX combines the Observer pattern with the Iterator pattern and functional programming with collections to fill the need for an ideal way of managing sequences of events.

Concepts in RxJS which solve ___async event management___ are:

__Observable__: represents the idea of an invokable collection of future values or events. 

- __Observer__: a collection of callbacks (__listeners__); handlers of values delivered by the Observable; Has methods: `next`, `error` and `complete`; each may invoke its callback (_subscription function_).

- __Schedulers__: centralized __dispatchers__ to control concurrency; `setTimeout`,  `requestAnimationFrame`, etc.

- __Subject__: the equivalent to an `EventEmitter`, and the only way of multicasting a value or event to multiple Observers.

__Subscription__: represents the execution of an Observable; an __ID__ for cancelling the execution.

__Operators__: pure functions (FP) for processing collections; `map`, `filter`, `concat`, `reduce`, etc.

## Observables and Observers

    OBSERVABLE source -> OBSERVER -> CALLBACK -> OBSERVABLE

- `Rx.Observable` class has many functions to create observables from different kind of data/streams; events, event patterns, arrays, promises, single/multiple value, any kind of data structure/primitive data types

```js
var clkOable = Rx.Observable.fromEvent(document, 'click')
clkOable.subscribe(aSubscrpnFn)

var arrOable = Rx.Observable.from(array)
arrOable.subscribe(aSubscrpnFn) 

var ajxOable = Rx.Observable.fromPromise(fetch(aURL))
ajxOable.subscribe(respFn, errFn)

// An Observer has 3 methods
someOable.subscribe({
    next: x => gotFn(x),
    error: err => errFn(err),
    complete: () => console.log('done'),
})

// Unsubscribe 
someOable.unsubscribe()
```

## Operators (Consumer &amp; Emitter)

    source OBSERVABLE -> OPERATOR FUNCTION -> destination OBSERVABLE 

```js
var arrOable = Rx.Observable.from([1, 2, 3, 4, 5])

arrOable
    .map(n => n * 2)
    .reduce((sum, n) => sum + n, 0) 
    .subscribe(function(n){
        console.log(n)
    }, function(err) {
        console.error(err)
    }, function() {
        console.log('done')
    })

```

#### @ `https://unpkg.com/rxjs@6.5.2/bundles/rxjs.umd.min.js` 

The above methods fail, e.g., `arrOable.map(..)` fails.

___Completely different methods/syntax required!___  

```js
arrOable = rxjs.from([1, 2, 3, 4, 5])

 arrOable
    .pipe(rxjs.operators.map(n => 2 * n))
    .pipe(rxjs.operators.reduce((sum,n) => sum + n,0))
    .subscribe(v => console.log(v)) 
```

## [`RxJS.js`](RxJS.js)

## `obs = Rx.Observable.create(fn)` 
Method to create a custom observable; returns an object having `subscribe` method on it.

## `obs.subscribe(obj)`
The `subscribe` method takes the __observer__ object (`obj`) as a param. It has methods: `next`, `error` and `complete`, which may be called (by `fn`) when an observable emits 

```js
{
    next: (v) => console.log('Got ' + v),
    error: (err) => console.error('ERR: ' + err),
    complete: () => console.log('done'),
}
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

