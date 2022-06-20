import
    std/[
        asynchttpserver,
        asyncdispatch,
        strformat,
        sugar,
        uri
    ],
    route,
    response,
    requestHandler

type
  CrabObj = object
    routes*: seq[Route]
    pageNotFoundHandler: RequestHandler
  Crab* = ref CrabObj

proc pageNotFoundHandler(request: Request): Response =
  newResponse("Page not found!", Http404, newHttpHeaders())

proc `$`*(crab: Crab): string =
  for route in crab.routes:
    result.add($route)

proc newCrab*(): Crab =
  result = new CrabObj
  result.pageNotFoundHandler = pageNotFoundHandler
  result.routes = newSeq[Route](0)

proc setPageNotFoundHandler*(crab: var Crab, handler: RequestHandler): void =
  crab.pageNotFoundHandler = handler

proc error*(message: string, code: HttpCode, headers: HttpHeaders): Response =
  newResponse(message, code, headers)

proc error*(message: string, code: HttpCode): Response =
  error(message, code, newHttpHeaders())

proc getRouteHandler(crab: Crab, request: Request): RequestHandler =
  let handlers = collect:
    for route in crab.routes:
      if route.path == $request.url and route.httpMethod == request.reqMethod:
        route.handler

  if handlers.len == 0:
    return crab.pageNotFoundHandler
  return handlers[0]

proc createHandler(crab: Crab): Future[(Request {.async, gcsafe.} -> Future[void])] {.async.} =
  proc handle(request: Request): Future[void] {.async.} =
    let
      requestHandler = crab.getRouteHandler(request)
      response = requestHandler(request)
    echo &"REQUEST: {request.reqMethod}\t{request.url}\tRESPONSE: {response.code}"

    await request.respond(response.code, response.body, response.headers)

  result = handle

proc run*(crab: Crab, port: int = 5000) {.async.} =
  var
    server = newAsyncHttpServer()
    requestHandler = await createHandler(crab)

  waitFor server.serve(Port(port), requestHandler)
