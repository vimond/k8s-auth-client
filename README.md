Kubernetes OIDC authentication client
=====================================

This script is intended to be used as a helper script to be used when using OIDC authentication together with Kubernetes.

The script authenticates with an OIDC compliant identity provider using the Resource Owner Password Credentials grant flow with 
a confidential client. It then sets the id and refresh tokens in the Kubernetes config file for the selected user,
 ready to be used by the Kubernetes kubectl command. The Kubernetes OIDC authenticator will attempt to fetch
 new tokens as needed.

This script has been tested using [Keycloak](http://www.keycloak.org/)

Please note that this script requires that a MFA (TOTP) code be used, for added security.
                              
Installation
-------------
Install the jq dependency (https://stedolan.github.io/jq/download/) if you don't already have it. For MacOS: 

`brew install jq`

Copy the [k8s-auth-client.sh](k8s-auth-client.sh) script somewhere on your path, and set it executable.

`chmod u+x k8s-auth-client.sh`

Create a config file named [.k8s-auth-client](.k8s-auth-client) in your home folder. Edit the values to fit your setup.

MacOS specific configuration:
###

Add a Keychain entry for the identity provider account you use to authenticate as a generic password. 
Name the entry `k8s-auth-client`, with the identity provider username in the "Account" field.


Usage
-----
`k8s-auth-client.sh <Kubernetes user to log in>`
 
 If you have set a MacOS Keychain password as described under installation these credentials will be fetched
 and used automatically. Any credentials configured in the config file will override these. If using the config
 file to store credentials please remember to restrict access to it appropriately.


