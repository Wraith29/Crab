# Crab

A simple API framwork written in Nim

This project was inspired by [Flask](https://flask.palletsprojects.com/en/2.1.x/)

Simple Setup:

```nim
import
    asyncdispatch,
    asynchttpserver,
    crab

proc idx(req: Request): Response =
    newResponse("Hello, World!", newHttpHeaders(), Http200)

proc cstErrHnd(req: Request): Response =
    newResponse("Page not found", newHttpHeaders(), Http404)

proc main(): Future[void] {.async.} =
    var
        crab = newCrab()

    crab.get("/", idx)
    crab.configureErrorHandler(cstErrHnd)

    waitFor crab.run()

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
