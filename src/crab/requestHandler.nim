import
    std/[
        asynchttpserver,
        sugar
    ],
    response

type
  RequestHandler* = (Request {.gcsafe.} -> Response)
