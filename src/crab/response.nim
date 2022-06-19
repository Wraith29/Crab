import
    asynchttpserver

type
  ResponseObj = object
    body*: string
    headers*: HttpHeaders
    code*: HttpCode
  Response* = ref ResponseObj

proc newResponse*(body: string, code: HttpCode,  headers: HttpHeaders): Response =
  result = new ResponseObj
  result.body = body
  result.code = code
  result.headers = headers

proc newResponse*(body: string, code: HttpCode): Response =
  newResponse(body, code, newHttpHeaders())
