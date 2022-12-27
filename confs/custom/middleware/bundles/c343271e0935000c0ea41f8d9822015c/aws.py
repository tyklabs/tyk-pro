import urllib3, json
http = urllib3.PoolManager()

def assumeRoleWebIdentity(jwt):
    payload = {
		'Action': 'AssumeRoleWithWebIdentity',
		'DurationSeconds': '3600',
		'RoleSessionName': 'user1',
		'WebIdentityToken': jwt,
		'RoleArn': 'arn:aws:iam::754489498669:role/googleOIDC',
		'Version': '2011-06-15'
	}

    response = http.request('GET', 'https://sts.amazonaws.com/', fields=payload)
    return response.data.decode('utf-8')