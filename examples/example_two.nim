import
    asyncdispatch, asynchttpserver, crab

proc login(req: Request): Response =
    newResponse("Logged In", Http200)

proc register(req: Request): Response =
    newResponse("User Created", Http200)

proc index(req: Request): Response =
    newResponse("Hello, World!", Http200)

proc pageNotFound(req: Request): Response =
    error("Page Not Found", Http404)

proc main() {.async.} =
    var 
        container = newContainer()
        app = newCrab()
    
    container.get("/auth/login", login)
    container.get("/auth/register", register)
    app.get("/", index)
    app.setPageNotFoundHandler(pageNotFound)

    app.addContainer(container)

    waitFor app.run()

when isMainModule:
    waitFor main()