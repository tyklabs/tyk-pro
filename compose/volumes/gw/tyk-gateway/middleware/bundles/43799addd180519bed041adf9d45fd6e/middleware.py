from tyk.decorators import *
from gateway import TykGateway as tyk
import anothermodule

print("loaded")


@Hook
def MyAuthMiddleware(request, session, metadata, spec):
    anothermodule.testfunction()
    print("auth called")
    add_header = request.add_header('Python_middleware', 'tyk')
    print(add_header)
    return request, session, metadata
