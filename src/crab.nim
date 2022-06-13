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
    errorHandler: RequestHandler
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
  result.errorHandler = defaultErrorRequestHandler
  result.routes = newSeq[Route](0)

proc configureErrorHandler*(crab: var Crab, errorHandler: RequestHandler): void =
  crab.errorHandler = errorHandler

proc createRoute*(path: string, httpMethod: HttpMethod, handler: RequestHandler): Route =
  result = new RouteObj
  result.path = path
  result.handler = handler
  result.httpMethod = httpMethod

proc route*(crab: var Crab, path: Uri | string, httpMethod: HttpMethod, handler: RequestHandler): void =
  if $path notin crab.routes.map(cr => cr.path):
    crab.routes.add(createRoute($path, httpMethod, handler))

proc get*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpGet, handler)

proc post*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpPost, handler)

proc put*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpPut, handler)

proc delete*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpDelete, handler)

proc trace*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpTrace, handler)

proc options*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpOptions, handler)

proc connect*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpConnect, handler)

proc patch*(crab: var Crab, path: Uri | string, handler: RequestHandler): void =
  crab.route(path, HttpPatch, handler)

proc getRouteHandler(crab: Crab, request: Request): RequestHandler =
  let handlers = collect:
    for route in crab.routes:
      if route.path == $request.url and route.httpMethod == request.reqMethod:
        route.handler

  if handlers.len <= 0:
    return crab.errorHandler
  return handlers[0]

proc createHandler(crab: Crab): Future[RequestHandler] {.async.} =
  proc handle(request: Request): Future[void] {.async.} =
    let requestHandler = crab.getRouteHandler(request)
    echo &"{request.reqMethod}:\t{$request.url}"
    await requestHandler(request)
  result = handle

proc run*(crab: Crab, port: int = 5000) {.async.} =
  var
    server = newAsyncHttpServer()
    requestHandler = await createHandler(crab)

  waitFor server.serve(Port(port), requestHandler)
