import
    std/[
        asynchttpserver,
        asyncdispatch,
        sugar
    ],
    route,
    response,
    requestHandler

type
  CrabObj = object
    routes*: seq[Route]
    errorHandler: RequestHandler
  Crab* = ref CrabObj

proc defaultErrorRequestHandler(request: Request): Response =
  newResponse("Page not found!", newHttpHeaders(), Http404)

proc `$`*(crab: Crab): string =
  for route in crab.routes:
    result.add($route)

proc newCrab*(): Crab =
  result = new CrabObj
  result.errorHandler = defaultErrorRequestHandler
  result.routes = newSeq[Route](0)

proc configureErrorHandler*(crab: var Crab, errorHandler: RequestHandler): void =
  crab.errorHandler = errorHandler

proc getRouteHandler(crab: Crab, request: Request): RequestHandler =
  let handlers = collect:
    for route in crab.routes:
      if route.path == $request.url and route.httpMethod == request.reqMethod:
        route.handler

  if handlers.len <= 0:
    return crab.errorHandler
  return handlers[0]

proc createHandler(crab: Crab): Future[(Request {.async, gcsafe.} -> Future[void])] {.async.} =
  proc handle(request: Request): Future[void] {.async.} =
    let
      requestHandler = crab.getRouteHandler(request)
      response = requestHandler(request)

    await request.respond(response.code, response.body, response.headers)

  result = handle

proc run*(crab: Crab, port: int = 5000) {.async.} =
  var
    server = newAsyncHttpServer()
    requestHandler = await createHandler(crab)

  waitFor server.serve(Port(port), requestHandler)
