import
  std/[
    asynchttpserver,
    strformat
  ],
  handlers

type Route* = ref object
  path*: string
  handler*: RequestHandler
  httpMethod*: HttpMethod

proc `$`*(route: Route): string =
  fmt"{route.path}, {route.httpMethod}"

proc newRoute*(path: string, httpMethod: HttpMethod, handler: RequestHandler): Route =
  new result
  result.path = path
  result.handler = handler
  result.httpMethod = httpMethod
