#!/bin/bash
#

set -e

VERSION=`cat VERSION`

docker build -t robinhoodis/jenkins:${VERSION} .
docker push robinhoodis/jenkins:${VERSION}

docker build -t robinhoodis/jenkins:latest .
docker push robinhoodis/jenkins:latest
