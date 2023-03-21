from tyk.decorators import *
from gateway import TykGateway as tyk
import json

@Hook
def MyResponseHook(request, response, session, metadata, spec):
    response_body = str(response.body)
    changed = response_body.upper().encode('utf-8')
    response.raw_body = changed
    response.headers["python-qa"] = "qa-test"

    return response, session, metadata, spec