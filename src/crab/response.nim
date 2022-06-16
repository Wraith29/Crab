import
    asynchttpserver

type
  ResponseObj = object
    body*: string
    headers*: HttpHeaders
    code*: HttpCode
  Response* = ref ResponseObj

proc newResponse*(body: string, headers: HttpHeaders, code: HttpCode): Response =
  result = new ResponseObj
  result.body = body
  result.headers = headers
  result.code = code
