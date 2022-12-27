from tyk.decorators import *
from gateway import TykGateway as tyk
from oauthlib.oauth2 import WebApplicationClient
import urllib3, json, base64, os
from aws import assumeRoleWebIdentity
from user import new_session_cookie, authenticate
http = urllib3.PoolManager()

# Configuration
GOOGLE_CLIENT_ID = os.environ.get("GOOGLE_CLIENT_ID", None)
GOOGLE_CLIENT_SECRET = os.environ.get("GOOGLE_CLIENT_SECRET", None)
GOOGLE_DISCOVERY_URL = (
    "https://accounts.google.com/.well-known/openid-configuration"
)
BASE_URL = "http://127.0.0.1:8080"

# OAuth2 client setup
client = WebApplicationClient(GOOGLE_CLIENT_ID)

def reply_with_unauthorized(request, session):
    request.object.return_overrides.headers['content-type'] = 'text/html'
    request.object.return_overrides.response_code = 403
    request.object.return_overrides.response_body = 'Unauthorized'
    return request, session

def reply_with_error(request, session, error_msg):
    request.object.return_overrides.headers['content-type'] = 'text/html'
    request.object.return_overrides.response_code = 500
    request.object.return_overrides.response_body = 'Server error'
    # TODO: log error using tyk.log
    # print(error_msg)
    return request, session

def home(request, session, spec):
    user_session = authenticate(request)
    if user_session:
        user_data = user_session['user_data']
        aws_data = user_session['aws_data']
        body = (
            "<p>Hello, {}! You're logged in! Email: {}</p>"
            "<div><p>Google Profile Picture:</p>"
            '<img src="{}" alt="Google profile pic"></img></div>'
            '<div><p>AWS CREDENTIALS:</p>'
            '<textarea rows="25" cols="100">{}</textarea></div>'
            '<a class="button" href="/logout">Logout</a>'.format(
               user_data['name'], user_data['email'], user_data['picture'], aws_data
            )
        )
        request.object.return_overrides.headers['content-type'] = 'text/html'
        request.object.return_overrides.response_code = 200
        request.object.return_overrides.response_body = body
        return request, session
    request.object.return_overrides.headers['content-type'] = 'text/html'
    request.object.return_overrides.response_code = 200
    request.object.return_overrides.response_body = '<a class="button" href="/login">Google Login</a>'
    return request, session

def login(request, session, spec):
    # Find out what URL to hit for Google login
    google_provider_cfg = get_google_provider_cfg()
    if not google_provider_cfg:
        return reply_with_error(request, session, "get_google_provider_cfg error")
    authorization_endpoint = google_provider_cfg["authorization_endpoint"]

    # Use library to construct the request for login and provide
    # scopes that let you retrieve user's profile from Google
    request_uri = client.prepare_request_uri(
        authorization_endpoint,
        redirect_uri=BASE_URL + "/login/callback",
        scope=["openid", "email", "profile"],
    )
    request.object.return_overrides.headers['location'] = request_uri
    request.object.return_overrides.response_code = 301
    return request, session

def callback(request, session, spec):
    # Get authorization code Google sent back to you
    code = request.object.params["code"]

    # Find out what URL to hit to get tokens that allow you to ask for
    # things on behalf of a user
    google_provider_cfg = get_google_provider_cfg()
    token_endpoint = google_provider_cfg["token_endpoint"]
    authorization = BASE_URL + request.object.request_uri

    # Prepare and send request to get tokens! Yay tokens!
    # why authorization and no authorization_response
    token_url, headers, body = client.prepare_token_request(
        token_endpoint,
        authorization=authorization,
        redirect_url=BASE_URL + "/login/callback",
        code=code,
    )

    # Prepare auth:
    authb64 = base64.b64encode(bytes('%s:%s' % (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET),'ascii'))
    headers = {"Authorization": "Basic " + authb64.decode('ascii'), "Content-Type": "application/x-www-form-urlencoded"}
    token_response = http.request('POST', token_url, headers=headers, body=body)
    token_response_data = json.loads(token_response.data.decode('utf-8'))
    user_jwt = token_response_data["id_token"]
    client.parse_request_body_response(token_response.data)

    # Now that we have tokens (yay) let's find and hit URL
    # from Google that gives you user's profile information,
    # including their Google Profile Image and Email
    userinfo_endpoint = google_provider_cfg["userinfo_endpoint"]
    uri, headers, body = client.add_token(userinfo_endpoint)
    userinfo_response = http.request('GET', uri, headers=headers, body=body)
    userinfo_response_json = json.loads(userinfo_response.data.decode('utf-8'))

    # We want to make sure their email is verified.
    # The user authenticated with Google, authorized our
    # app, and now we've verified their email through Google!
    if 'email_verified' not in userinfo_response_json:
        return reply_with_unauthorized(request, session)
    if not userinfo_response_json['email_verified']:
        return reply_with_unauthorized(request, session)

    # Request AWS Temp credentials
    awsTempCredentials = assumeRoleWebIdentity(user_jwt)

    # Set cookie:
    set_cookie_value = new_session_cookie(userinfo_response_json, awsTempCredentials)
    request.object.return_overrides.headers["Set-Cookie"] = set_cookie_value
    # Redirect to home page:
    request.object.return_overrides.headers['location'] = BASE_URL + "/"
    request.object.return_overrides.response_code = 301
    return request, session

def get_google_provider_cfg():
    try:
        res = http.request('GET', GOOGLE_DISCOVERY_URL)
        return json.loads(res.data)
    except:
        # TODO: do some error handling
        print("get_google_provider_cfg error")
    return None

@Hook
def hook(request, session, spec):
    if request.object.url == "/":
        return home(request, session, spec)
    if request.object.url == "/login":
        return login(request, session, spec)
    if request.object.url.startswith("/login/callback"):
        return callback(request, session, spec)
    # For all other request paths, reply with HTTP 401:
    return reply_with_unauthorized(request, session)
