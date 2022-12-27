from gateway import TykGateway as tyk
from http.cookies import Morsel, SimpleCookie
import secrets, json

# DEFAULT_SESSION_TTL specifies Redis key TTL in seconds:
DEFAULT_SESSION_TTL = 10000
# TOKEN_PREFIX specifies token prefix
TOKEN_PREFIX = 'internal-auth'
# TOKEN_LENGTH specifies token length for secrets module
TOKEN_LENGTH = 32

# generate a session ID with given length (TOKEN_LENGTH) and TOKEN_PREFIX:
# TOKEN_PREFIX-[token]
def gen_session_id():
    token_hex = secrets.token_hex(TOKEN_LENGTH)
    return "{0}-{1}".format(TOKEN_PREFIX, token_hex)

# first: generate a new "safe token" using secrets module
# second: build a cookie containing this token
# third: store session data into Redis
# finally return cookie value (to be set with Set-Cookie header)
def new_session_cookie(user_data, aws_data):
    session_id = gen_session_id()
    m = Morsel()
    # Set reserved keys first:
    m['expires'] = 165856168
    m['path'] = '/'
    # Set session ID:
    m.set('session_id', session_id, session_id)
    cookie_value = get_cookie_value(m)
    session_data = {'user_data': user_data, 'aws_data': aws_data}
    raw_session_data = json.dumps(session_data)
    tyk.store_data(session_id, raw_session_data, 10000)
    return cookie_value

# returns cookie header value
def get_cookie_value(morsel):
    output = morsel.output()
    return output[len("Set-Cookie: "):] if output.startswith("Set-Cookie: ") else output

# retrieve session data from Redis, using given session_id
def get_session(session_id):
    try:
        raw_session_data = tyk.get_data(session_id)
        session_data = json.loads(raw_session_data)
        return session_data
    except:
        return None

# extract the cookie value from header
# and use get_session to 
def authenticate(request):
    cookie_header = request.object.headers['Cookie']
    if cookie_header:
        c = SimpleCookie()
        c.load(cookie_header)
        session_morsel = c.get("session_id")
        if not session_morsel:
            return None
        session_id = session_morsel.value
        session = get_session(session_id)
        if session:
            return session
    return None