import
    asyncdispatch, asynchttpserver, crab

proc idx(req: Request): Response =
    var validUser = false
    if not validUser:
        return error("Invalid User", Http401)
    return newResponse("Hi There", Http200)

proc main() {.async.} =
    var app = newCrab()
    app.get("/", idx)
    
    waitFor run(app)

when isMainModule:
    waitFor main()