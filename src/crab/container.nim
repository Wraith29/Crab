import route

type Container* = seq[Route]

func newContainer*(): Container {.inline.} =
  result = @[]

func `$`*(container: Container): string {.inline.} =
  for route in container:
    result.add($route)
