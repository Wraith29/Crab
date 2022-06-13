# Crab

Nim web framework slightly inspired by Flask

Example:

```nim
import
    asyncdispatch,
    asynchttpserver,
    crab

proc idx(req: Request): Future[void] {.async, gcsafe.} =
    await req.respond(Http200, "Hello, World!", newHttpHeaders())

proc hlo(req: Request): Future[void] {.async, gcsafe.} =
    await req.respond(Http200, "Goodbye, Mars!", newHttpHeaders())

proc pst(req: Request): Future[void] {.async, gcsafe.} =
    await req.respond(Http200, "UwU", newHttpHeaders())

proc cstErrHnd(req: Request): Future[void] {.async, gcsafe.} =
    await req.respond(Http404, "Error, Page not Found!", newHttpHeaders())

proc main(): Future[void] {.async.} =
    var
        crab = createCrab()

    crab.get("/", idx)
    crab.get("/h", hlo)
    crab.post("/i", pst)
    crab.configureErrorHandler(cstErrHnd)

    waitFor crab.run()

when isMainModule:
    waitFor main()
```
