#!/bin/bash

set -e

pkcs7=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | paste -s -d '')
result=$(curl -X POST "http://10.0.1.161:8200/v1/auth/aws-ec2/login" -d '{"role":"myapp","pkcs7":"'"$pkcs7"'","nonce":"vault-client-nonce"}')
token=$( jq -r .auth.client_token <<< "$result" )
policies=$( jq -r .auth.policies[] <<< "$result" )
ami_id=$( jq -r .auth.metadata.ami_id <<< "$result" )
[[ -n $token ]] || exit 1


echo "Successfully authenticated:"
echo "     Token: $token"
echo "  Policies:" $policies
echo "    AMI ID: $ami_id"

echo "...testing out the auth....what is my favorite color ??? It's..."
color=$(curl -s http://10.0.1.161:8200/v1/secret/example/favorites -H "X-Vault-Token:$token"| jq -r .data.color)
echo $color
