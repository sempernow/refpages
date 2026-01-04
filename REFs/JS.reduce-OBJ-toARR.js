const log = (arg, ...args) => console.log(arg, ...args)
    ,list = [{id:1,b:2},{id:22,b:55}]
    ,a = list.reduce((acc,o) => {
        acc.push(o.id)
        return acc 
    }, [])

log(a) // [1, 22]


