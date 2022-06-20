import
    asyncdispatch, asynchttpserver, crab

proc idx(req: Request): Response =
    return newResponse("Hi There", Http200)

proc main() {.async.} =
    var app = newCrab()
    app.get("/", idx)

    app.addRequiredHeader("BearerToken")

    waitFor run(app)

when isMainModule:
    waitFor main()