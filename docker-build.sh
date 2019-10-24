#!/bin/sh
set -e

mainFolderPath=$(pwd)
trace=yes
REPONAME=mssxplat
VERSION=0.1.0
IMAGE_NAME="tippecanoe-net"

if [ "${trace}" = "yes" ]; then
    echo "Start Docker-Build"
    echo "mainFolderPath=${mainFolderPath}"
    echo "REPONAME=${REPONAME}"
    echo "VERSION=${VERSION}"
fi;

echo ""
tag=${REPONAME}/${IMAGE_NAME}:${VERSION}
latest=${REPONAME}/${IMAGE_NAME}:latest
echo "Start Docker build for tag '${tag} using Context '${mainFolderPath}/src/'"
docker build -f src/Dockerfile -t ${tag} .
docker tag ${tag} ${latest}
echo "docker build completed."
