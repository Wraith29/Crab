import
  asynchttpserver

type Response* = ref object
  body*: string
  headers*: HttpHeaders
  code*: HttpCode

func newResponse*(body: string, code: HttpCode,  headers: HttpHeaders): Response =
  new result
  result.body = body
  result.code = code
  result.headers = headers

func newResponse*(body: string, code: HttpCode): Response =
  newResponse(body, code, newHttpHeaders())
