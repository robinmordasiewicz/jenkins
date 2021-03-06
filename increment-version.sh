#!/bin/bash
#

set -e

curl -s -L https://updates.jenkins.io/stable/latestCore.txt --output JENKINS_VERSION
#curl -s -L https://updates.jenkins.io/current/latestCore.txt --output JENKINS_VERSION

JENKINS_VERSION=`cat JENKINS_VERSION`
LOCALREVISION=`cat VERSION | sed -re "s/^[0-9]+\.[0-9]+\.[0-9]+-*([0-9]*)/\1/" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`

echo "${JENKINS_VERSION}-${LOCALREVISION}" > VERSION

cat Dockerfile | sed -re "s/FROM.*/FROM jenkins\/jenkins:${JENKINS_VERSION}/" > Dockerfile.tmp && mv Dockerfile.tmp Dockerfile

