import
    route

type
    Container* = seq[Route]

proc newContainer*(): Container {.inline.} =
    result = @[]

proc `$`*(container: Container): string {.inline.} =
    for route in container:
        result.add($route)
