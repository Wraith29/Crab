# Crab

A simple API framwork written in Nim

This project was inspired by [Flask](https://flask.palletsprojects.com/en/2.1.x/)

Simple Setup:

```nim
import asyncdispatch, asynchttpserver, crab

proc indexRoute(req: Request): Future[void] {.async.} =
  await req.respond(Http200, "Hello, World!", newHttpHeaders())

proc main(): Future[void] {.async.} =
  var
    app = createCrab()

  crab.get("/", index)

  waitFor crab.run(1234) # Port Number, defaults to 5000

when isMainModule:
  waitFor main()
```

404 Page not found method is by default a simple string saying "Page not found".

This can be changed with the creation of a custom error route:

```nim
proc customErrorRoute(req: Request): Future[void] {.async.} =
  await req.respond(Http400, "Custom Message", newHttpHeaders())

...
app.configureErrorHandler(customErrorRoute)
```
