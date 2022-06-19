# Crab

A simple API framwork written in Nim

This project was inspired by [Flask](https://flask.palletsprojects.com/en/2.1.x/)

Simple Setup:

```nim
import
    asyncdispatch,
    asynchttpserver,
    crab

proc index(request: Request): Response =
    var isUserValid = isUserValid()
    if not isUserValid:
        error("Invalid User", Http401)
    newResponse("Home Page", Http200)

proc main() {.async.} =
    var app = newCrab()
    app.get("/", index)

    waitFor app.run()

when isMainModule:
    waitFor main()
```

404 Page not found method is by default a simple string saying "Page not found".

This can be changed with the creation of a custom error route:

```nim
proc customErrorRoute(request: Request): Response =
    newResponse("Not Found", newHttpHeaders(), Http404)
...
app.configureErrorHandler(customErrorRoute)
```
