import
    asyncdispatch,
    asynchttpserver,
    crab

proc idx(req: Request): Future[void] {.async, gcsafe.} =
    await req.respond(Http200, "Hello, World!", newHttpHeaders())

proc hlo(req: Request): Future[void] {.async, gcsafe.} =
    await req.respond(Http200, "Goodbye, Mars!", newHttpHeaders())

proc main(): Future[void] {.async.} =
    var
        crab = createCrab()

    crab.addRouteHandler("/", HttpGet, idx)
    crab.addRouteHandler("/h", HttpGet, hlo)

    waitFor crab.run()

when isMainModule:
    waitFor main()
