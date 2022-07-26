import
  std/[
    asynchttpserver,
    asyncdispatch,
    sugar
  ],
  response

type 
  RequestHandler* = (Request {.gcsafe.} -> Response)
  Handler* = (Request {.async, gcsafe.} -> Future[void])