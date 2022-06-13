import
  asynchttpserver,
  asyncdispatch,
  uri,
  strutils,
  strformat,
  sequtils,
  sugar

type
  RequestHandler = (Request {.async, gcsafe.} -> Future[void])
  RouteObj = object
    path*: string
    handler*: RequestHandler
    httpMethod*: HttpMethod
  Route* = ref RouteObj

  CrabObj = object
    routes: seq[Route]
  Crab* = ref CrabObj

proc defaultErrorRequestHandler(request: Request): Future[void] {.async, gcsafe.} =
  await request.respond(Http404, "Page Not Found!", newHttpHeaders())

proc `$`*(route: Route): string =
  fmt"{route.path}, {route.httpMethod}"

proc `$`*(crab: Crab): string =
  for route in crab.routes:
    result.add($route)

proc createCrab*(): Crab =
  result = new CrabObj
  result.routes = newSeq[Route](0)

proc createRoute*(path: string, httpMethod: HttpMethod, handler: RequestHandler): Route =
  result = new RouteObj
  result.path = path
  result.handler = handler
  result.httpMethod = httpMethod

proc addRouteHandler*(crab: var Crab, path: string, httpMethod: HttpMethod, handler: RequestHandler): void =
  let routes = crab.routes.map(cr => cr.path)

  if path notin routes:
    crab.routes.add(createRoute(path, httpMethod, handler))

proc addRouteHandler*(crab: var Crab, route: Uri, httpMethod: HttpMethod, handler: RequestHandler): void =
  crab.addRouteHandler($route, httpMethod, handler)

proc getRouteHandler(crab: Crab, request: Request): RequestHandler =
  let handlers = collect:
    for route in crab.routes:
      if route.path == $request.url and route.httpMethod == request.reqMethod:
        route.handler

  if handlers.len <= 0:
    return defaultErrorRequestHandler
  return handlers[0]

proc createHandler(crab: Crab): Future[RequestHandler] {.async.} =
  proc handle(request: Request): Future[void] {.async.} =
    let requestHandler = crab.getRouteHandler(request)
    echo fmt"{request.reqMethod}: {$request.url}"
    await requestHandler(request)
  result = handle

proc run*(crab: Crab, port: int = 5000) {.async.} =
  var
    server = newAsyncHttpServer()
    requestHandler = await createHandler(crab)

  waitFor server.serve(Port(port), requestHandler)
