#!/bin/bash -x
if [ "$#" -ne 1 ] ; then
  echo "Usage: k8s-auth-client.sh <K8S account name> " >&2
  exit 1
fi

KUBE_CONFIG_USERNAME=$1

#Basic error handling
set -o errexit
set -o pipefail

source ~/.kube/$KUBE_CONFIG_USERNAME.k8s-auth-client

if [[ -z $K8S_AUTH_USERNAME || -z $K8S_AUTH_PASSWORD ]]; then
	#fetch password from keychain
	K8S_AUTH_USERNAME=$(security find-generic-password -s k8s-auth-client | grep 'acct' | cut -d \" -f4)
	K8S_AUTH_PASSWORD=$(security find-generic-password -s k8s-auth-client -w)
fi

set -o nounset


read -p 'MFA code:' TOTP

#fetch and parse tokens from Keycloak
KEYCLOAK_RESPONSE=$(curl -# --data "grant_type=password&client_id=$K8S_OIDC_CLIENT_ID&username=$K8S_AUTH_USERNAME&password=$K8S_AUTH_PASSWORD&scope=openid&client_secret=$K8S_OIDC_CLIENT_SECRET&totp=$TOTP" $K8S_OIDC_TOKEN_ENDPOINT)
K8S_REFRESH_TOKEN=$(echo ${KEYCLOAK_RESPONSE} | jq -r '.refresh_token')
K8S_ID_TOKEN=$(echo ${KEYCLOAK_RESPONSE} | jq -r '.id_token')

#set Kubernetes credentials
kubectl config set-credentials $KUBE_CONFIG_USERNAME \
	--auth-provider=oidc \
	--auth-provider-arg=idp-issuer-url=$K8S_OIDC_ISSUER \
	--auth-provider-arg=client-id=$K8S_OIDC_CLIENT_ID \
	--auth-provider-arg=client-secret=$K8S_OIDC_CLIENT_SECRET \
	--auth-provider-arg=refresh-token=$K8S_REFRESH_TOKEN \
	--auth-provider-arg=id-token=$K8S_ID_TOKEN
