import
  std/[
    asynchttpserver,
    sequtils,
    sugar,
    uri
  ],
  crab,
  route,
  container,
  handlers

type Path = Uri | string

proc route*(crab: var Crab, path: Path, httpMethod: HttpMethod, handler: RequestHandler): void =
  if $path notin crab.routes.map(cr => cr.path):
    crab.routes.add(newRoute($path, httpMethod, handler))

proc route*(crab: var Crab, route: Route): void =
  crab.route(route.path, route.httpMethod, route.handler)

proc route*(container: var Container, path: Path, httpMethod: HttpMethod, handler: RequestHandler): void =
  if $path notin container.map(cr => cr.path):
    container.add(newRoute($path, httpMethod, handler))

proc get*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpGet, handler)

proc get*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpGet, handler)

proc post*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpPost, handler)

proc post*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpPost, handler)

proc put*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpPut, handler)

proc put*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpPut, handler)

proc delete*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpDelete, handler)

proc delete*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpDelete, handler)

proc trace*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpTrace, handler)

proc trace*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpTrace, handler)

proc options*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpOptions, handler)

proc options*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpOptions, handler)

proc connect*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpConnect, handler)

proc connect*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpConnect, handler)

proc patch*(crab: var Crab, path: Path, handler: RequestHandler): void =
  crab.route(path, HttpPatch, handler)

proc patch*(container: var Container, path: Path, handler: RequestHandler): void =
  container.route(path, HttpPatch, handler)

proc addContainer*(crab: var Crab, container: Container): void =
  for route in container:
    crab.route(route)