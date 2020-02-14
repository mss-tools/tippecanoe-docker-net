#!/bin/sh
set -e

mainFolderPath=$(pwd)
trace=yes
IMAGE_NAME="tippecanoe-net"

if [ "${trace}" = "yes" ]; then
    echo "Start Docker-Build"
    echo "mainFolderPath=${mainFolderPath}"
fi;

echo ""
tag=${IMAGE_NAME}:latest
echo "Start Docker build for tag '${tag} using Context '${mainFolderPath}/src/'"
docker build ./src --file ./src/Dockerfile --tag ${tag}
echo "docker build completed."
