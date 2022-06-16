import
    std/[
        asynchttpserver,
        sequtils,
        sugar,
        uri
    ],
    crab,
    route,
    requestHandler

proc route*(crab: var Crab, path: Uri | string, httpMethod: HttpMethod, handler: RequestHandler): void =
  if $path notin crab.routes.map(cr => cr.path):
    crab.routes.add(newRoute($path, httpMethod, handler))

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
