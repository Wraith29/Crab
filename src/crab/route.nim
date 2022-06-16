import
    std/[
        asynchttpserver,
        strformat
    ],
    requestHandler

type
  RouteObj = object
    path*: string
    handler*: RequestHandler
    httpMethod*: HttpMethod
  Route* = ref RouteObj

proc `$`*(route: Route): string =
  fmt"{route.path}, {route.httpMethod}"

proc newRoute*(path: string, httpMethod: HttpMethod, handler: RequestHandler): Route =
  result = new RouteObj
  result.path = path
  result.handler = handler
  result.httpMethod = httpMethod
