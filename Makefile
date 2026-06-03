
# THIS IS JUST TO SEE HOW THE AUTHORIZAITON CODE FLOW WITH PKCE WORKS USING SIMPLE HTTP REQUESTS

KEYCLOAK_BASE_URI=http://localhost:8080
REALM_NAME=auth_demo
REDIRECT_URI=https://localhost:5001

#64 CHAR STRING
CODE_VERIFIER=KupTYA86yxt1zDmev2vrjCRCHEl2wl8pB5nHG1LkpsfG4S9K6HOsFajS3itPBsyJ

# BASE64(SHA256(CODE_VERIFIER))
CODE_CHALLENGE=D4m4J7xWR7tjMRz74RatKuORK5DYLUxl5KpFkDurgG8

CODE_CHALLENGE_METHOD=S256

# TO PREVENT CSRF ATTACKS
STATE=6HOsFajS3itPBsyJ

# public-client-audience-scope IS NEEDED TO GET THE CORRECT AUDIENCE FOR THE API
SCOPE=openid profile email public-client-audience-scope

CLIENT_ID=public-client



CODE=50f90107-7f17-4fe8-eebf-4b9b6255af71.sjB1NXRLuab0LRij72qHiAb6.4b231c94-0a48-46b3-85d4-b417f0b9948b

ACCESS_TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJDR1VNem5LVXhRdGpLb2VVdjdEbnlfQWU2NGxMZzF3UWp4eGJhbnloNkUwIn0.eyJleHAiOjE3ODA0ODg3NTMsImlhdCI6MTc4MDQ4ODQ1MywiYXV0aF90aW1lIjoxNzgwNDg3MzM5LCJqdGkiOiJvbnJ0YWM6OTU4ZjU3NDktMGNjOS0wYjljLWEzMmQtNzA0MTc3YTAwY2ZhIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwL3JlYWxtcy9hdXRoX2RlbW8iLCJhdWQiOlsicHVibGljLWNsaWVudCIsImFjY291bnQiXSwic3ViIjoiY2FmM2NmZGYtMTY1Zi00MDkzLWI0MjUtYWJmOWQyNWEzNjM5IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoicHVibGljLWNsaWVudCIsInNpZCI6InNqQjFOWFJMdWFiMExSaWo3MnFIaUFiNiIsImFjciI6IjAiLCJhbGxvd2VkLW9yaWdpbnMiOlsiaHR0cHM6Ly9sb2NhbGhvc3Q6NTAwMSJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiZGVmYXVsdC1yb2xlcy1hdXRoX2RlbW8iLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwibmFtZSI6Ik1pa2UgTmlja2Vsc29uIiwicHJlZmVycmVkX3VzZXJuYW1lIjoidXNlcjEiLCJnaXZlbl9uYW1lIjoiTWlrZSIsImZhbWlseV9uYW1lIjoiTmlja2Vsc29uIiwiZW1haWwiOiJhYWFAbWFpbC5ydSJ9.P1oWkRq6LN3DC13MoZKc1YPzDwKQ1hieE4RU9PXsaCBfnrJY3ZO8yGV1UcGQJz9Tgb-14OjLScPYZZA37S-emh_f16qw7_Y7NnGsSQGCMWQQBcOmSa4WryA1KiE9rREpoAZwyH701zd5f5qJnI-LaRsIItmC7HAKv22sDIu4aIu8pIU_1mUtYtNiMIESBTYAiRVvSGeuNHZ5ejLn_EzQv5a5v9yyyBsJFoLKt8Yc3nZdfictm2xr53BHj3ibwMYa8pFAt7xtqIGTd0RvyITFYHGwERVDcoB2Kirfhv5K3at2SrW2X8Yyt8OkiKLQktKBpc1MrSB1VPJuOBHwALZABg


# IT'LL SAY "URL REJECTED". BUT WE JUST NEED TO FOLLOW THE LINK THAT CURL GENERATES
get_authorization_code:
	curl -X GET "$(KEYCLOAK_BASE_URI)/realms/$(REALM_NAME)/protocol/openid-connect/auth?response_type=code&client_id=$(CLIENT_ID)&scope=$(SCOPE)&redirect_uri=$(REDIRECT_URI)&code_challenge=$(CODE_CHALLENGE)&code_challenge_method=$(CODE_CHALLENGE_METHOD)&state=$(STATE)"

# FROM get_authorization_code WE NEED TO GET THE CODE AND ASSIGN IT TO THE CODE VARIABLE
get_access_token:
	curl -X POST "$(KEYCLOAK_BASE_URI)/realms/$(REALM_NAME)/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" \
		-d "grant_type=authorization_code" \
		-d "client_id=$(CLIENT_ID)" \
		-d "code=$(CODE)" \
		-d "code_verifier=$(CODE_VERIFIER)" \
		-d "redirect_uri=$(REDIRECT_URI)" 

# FROM get_access_token WE NEED TO GET THE ACCESS TOKEN AND ASSIGN IT TO THE ACCESS_TOKEN VARIABLE
try_get_protected_data:
	curl -X GET "https://localhost:5001/users/me" -H "Authorization: Bearer $(ACCESS_TOKEN)"