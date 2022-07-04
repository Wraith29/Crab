import
    std/[
        asynchttpserver,
        asyncdispatch,
        strformat,
        strutils,
        tables,
        sugar,
        uri
    ],
    route,
    response,
    requestHandler

type
  CrabObj = object
    routes*: seq[Route]
    requiredHeaders*: seq[string]
    missingRequiredHeaderHandler: RequestHandler
    pageNotFoundHandler: RequestHandler
  Crab* = ref CrabObj

proc pageNotFoundHandler(request: Request): Response =
  newResponse("Page not found!", Http404, newHttpHeaders())

proc missingRequiredHeaderHandler(request: Request): Response =
  newResponse("Missing Required Header", Http404, newHttpHeaders())

proc `$`*(crab: Crab): string =
  for route in crab.routes:
    result.add($route)

proc newCrab*(): Crab =
  result = new CrabObj
  result.pageNotFoundHandler = pageNotFoundHandler
  result.missingRequiredHeaderHandler = missingRequiredHeaderHandler
  result.routes = @[]
  result.requiredHeaders = @[]

proc setMissingRequiredHeaderHandler*(crab: var Crab, handler: RequestHandler): void {.inline.} =
  crab.missingRequiredHeaderHandler = handler

proc setPageNotFoundHandler*(crab: var Crab, handler: RequestHandler): void {.inline.} =
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

proc addRequiredHeader*(crab: var Crab, header: string): void {.inline.} =
  crab.requiredHeaders.add(header)

proc hasRequiredHeaders*(crab: Crab, req: Request): bool =
  for rh in crab.requiredHeaders:
    if not req.headers.table.hasKey(rh.toLowerAscii):
      return false
  true

proc createHandler(crab: Crab, debug: bool): Future[(Request {.async, gcsafe.} -> Future[void])] {.async.} =
  proc handle(request: Request): Future[void] {.async.} =
    let requestHandler = crab.getRouteHandler(request)
    var response: Response

    if crab.hasRequiredHeaders(request):
      response = requestHandler(request)
    else:
      response = crab.missingRequiredHeaderHandler(request)

    if debug:
      echo &"REQUEST: {request.reqMethod}\t{request.url}\tRESPONSE: {response.code}"
    await request.respond(response.code, response.body, response.headers)

  result = handle

proc run*(crab: Crab, port: int = 5000, debug: bool = false) {.async.} =
  var
    server = newAsyncHttpServer()
    requestHandler = await createHandler(crab, debug)

  waitFor server.serve(Port(port), requestHandler)
