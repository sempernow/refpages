# [What is a REST API](https://www.quora.com/What-is-a-REST-API "2017 Quora.com :: Ruben Verborgh, Professor of Semantic Web technology, MIT")
##  4 Rules (`TL;DR`) 
1. Offer access through resources
    - Things; addresses, not instructions per se.
2. Represent resources by representations
    - One address per thing. (E.g., not per format.)
3. Exchange self-descriptive messages
    - Stand-alone messages; xfr per standards only (E.g., HTTP methods.)
4. Connect resources through links
    - All things are addressed, and only by their (unique) hyperlinks.

# 
## [Representaional State Transfer (REST)](https://en.wikipedia.org/wiki/Representational_state_transfer "Wikipedia") 

A REST API leverages HTTP request _types_ to indicate the desired action. The characteristics of REST are the __four rules__ of __uniform interface__:  

1. Offer access through resources
2. Represent resources by representations
3. Exchange self-descriptive messages
4. Connect resources through links

APIs that follow these rules are REST APIs. 

## 1. Offer access through resources

#### NOT REST

    /changeTodoList.php?item=35&action=changeTitle&title=new_title

Note how this is indeed __an instruction__: change something. But a “changeTodoList” is __not a thing__, it's __not a resource__. 

__In the REST architectural style, servers only offer resources__. Resources are conceptual things about which clients and servers communicate.

#### REST

    /todolists/7/items/35/

This above thing is not a command, it is the __address of a resource, a thing__. You can then use this address to manipulate the to-do list using standard operations, instead of interface-specific commands.

## 2. Represent resources by representations

A resource is a thing —and we can describe those things in _different formats_. For instance, humans might want to see an HTML version, which your browser transforms into a readable layout. But sometimes, interfaces on the Web are used by machines, too. They need a different format, such as JSON.

In a non-REST way, __different formats have different addresses__:

#### NOT REST

    browser:     /showTodoList.php?format=html
    application: /showTodoList.php?format=json

The problem is then that __systems using different formats cannot communicate with each other__, because they use different addresses for the same things!  

__In a REST system__, addresses identify things, not formats, so all systems use __the same address for the same thing__. How can they get different formats then? They explicitly ask for it! The technique that enables this is called ___content negotiation___; one URI for many formats, "_negotiated_" per __HTTP Headers__ ([MD](Network.HTTP.Headers.html#content-negotiation "@ browser")). E.g., &hellip; 

- `Accept: <MIME_type>/<MIME_subtype>`

#### REST

    browser:     /todolists/7/  +Header: Accept: text/html
    application: /todolists/7/  +Header: Accept: Accept: application/json


## 3. Exchange self-descriptive messages

In a REST system, we should be able to interpret any message without having seen the previous one. Imagine the following conversation:

#### NOT REST

    /search-results?q=todo
    /search-results?page=2
    /search-results?page=3

The first request gets search results for “todo”; the second request gets the second page of that. Now imagine that you only see the second request. How would you know as a server what to do? In REST, each message stands on its own:

#### REST

    /search-results?q=to-do
    /search-results?q=todo&page=2
    /search-results?q=todo&page=3

Note how __each request can be interpreted by itself__. Another aspect of this, is that REST clients and servers __only use standard operations__, which are defined in a specification. _For the Web, this specification is called HTTP_.

## 4. Connect resources through links

How can you navigate a website you've never seen before? You use links! You don't have to manually edit the address bar in your browser every time you go to a new page.

In machine interfaces, this is not always the case. Suppose an application asks for your to-do list. It might receive the following representation:

#### NOT REST

    /todolists/7/

    {
      "name": "My to-dos",
      "items": [35, 36]
    }

Now how can you get the items of the list? Good question! We'd have to read the documentation for that. In REST, __resources connect to each other through hyperlinks__:

#### REST

    /todolists/7/

    {
      "name": "My to-dos",
      "items": ["/todolists/7/items/35/", "/todolists/7/items/36/"]
    }

Note how you don't have to read the manual to know how you can retrieve the items of your list. You just follow the links.

## [Hypermedia](https://en.wikipedia.org/wiki/Hypermedia "Wikipedia") APIs
Many interfaces that label themselves as “REST” are actually something else (“HTTP interfaces”), because they don't follow all of the rules. 

__Rules 2__ and __4__ __are often violated__, but it's not entirely uncommon to see rule 1 being violated as well. For those developers, “REST” simple means “we didn't do the XML messages thing”.

REST interfaces that follow all four rules are now often called “__hypermedia APIs__”, referring to the __fourth rule__.


### &nbsp;
<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

