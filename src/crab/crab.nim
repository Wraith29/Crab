import
  std/[
    asynchttpserver,
    asyncdispatch,
    strformat,
    strutils,
    sugar,
    uri
  ],
  route,
  response,
  handlers

type Crab* = ref object
  routes*: seq[Route]
  requiredHeaders*: seq[string]
  missingRequiredHeaderHandler: RequestHandler
  pageNotFoundHandler: RequestHandler

func `$`*(crab: Crab): string =
  for route in crab.routes:
    result.add($route)

func newCrab*(): Crab =
  new result
  result.pageNotFoundHandler = ((request: Request) {.gcsafe.} => newResponse("Page not Found!", Http404))
  result.missingRequiredHeaderHandler = ((request: Request) {.gcsafe.} => newResponse("Missing Required Header", Http400))
  result.routes = @[]
  result.requiredHeaders = @[]

func setMissingRequiredHeaderHandler*(crab: var Crab, handler: RequestHandler): void {.inline.} =
  crab.missingRequiredHeaderHandler = handler

func setPageNotFoundHandler*(crab: var Crab, handler: RequestHandler): void {.inline.} =
  crab.pageNotFoundHandler = handler

func error*(message: string, code: HttpCode, headers: HttpHeaders): Response =
  newResponse(message, code, headers)

func error*(message: string, code: HttpCode): Response =
  error(message, code, newHttpHeaders())

proc getRouteHandler(crab: Crab, request: Request): RequestHandler =
  let handlers = collect:
    for route in crab.routes:
      if route.path == $request.url and route.httpMethod == request.reqMethod:
        route.handler

  if handlers.len == 0:
    return crab.pageNotFoundHandler
  handlers[0]

func addRequiredHeader*(crab: var Crab, header: string): void {.inline.} =
  crab.requiredHeaders.add(header)

func hasRequiredHeaders*(crab: Crab, req: Request): bool =
  for requiredHeader in crab.requiredHeaders:
    if not req.headers.hasKey(requiredHeader.toLowerAscii):
      return false
  true

proc createHandler(crab: Crab, debug: bool): Future[Handler] {.async.} =
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
