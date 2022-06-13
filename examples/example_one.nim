import
    asyncdispatch,
    asynchttpserver,
    crab

proc idx(req: Request) {.async.} =
    await req.respond(Http200, "Hello, World!", newHttpHeaders())

proc cstErrHnd(req: Request) {.async.} =
    await req.respond(Http404, "Error, Page not Found!", newHttpHeaders())

proc main(): Future[void] {.async.} =
    var
        crab = newCrab()

    crab.get("/", idx)
    crab.configureErrorHandler(cstErrHnd)

    waitFor crab.run()

when isMainModule:
    waitFor main()
