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
