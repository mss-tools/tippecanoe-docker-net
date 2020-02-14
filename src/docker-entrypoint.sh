#!/bin/sh
set -e
export PATH="$PATH:/root/.dotnet/tools"
echo ""
echo "Tippecanoe Runner CLI v1.0.6"
echo ""

# settings
trace=yes

if [ -z "$1" ]
then
      trace=no
else
      trace=yes
fi

mainFolderPath=$(pwd)
OUTER_FOLDER=$mainFolderPath/data_tiles
FILTER=./splits/*.geojson
SUBFOLDERCOLOR=outdoor

if [ "${trace}" = "yes" ]; then
  echo "PWD=${mainFolderPath}"
  echo "STORAGE=${STORAGE}"
  echo "CONTAINER=${CONTAINER}"
  echo "SUBPATH_MBTILES=${SUBPATH_MBTILES}"
  echo "SUBPATH_GEOJSON=${SUBPATH_GEOJSON}"
  echo "FILTER=$FILTER"
  echo "OUTER_FOLDER=$OUTER_FOLDER"
fi;

mkdir -p $OUTER_FOLDER
mkdir -p ./splits

echo "Start download from Azure Blob Container: [${CONTAINER}] ${SUBPATH_GEOJSON} => ./splits"
azureblob download --localdirectory ./splits --connectionstring $STORAGE --container $CONTAINER --azuredirectory $SUBPATH_GEOJSON --mask "*.geojson" --verbosity d
echo ""
echo "Download completed!"

GEOJSON_LIST=""
for f in $FILTER; do
  b=$(basename $f)
  inputname="./splits/${b}"
  GEOJSON_LIST="${GEOJSON_LIST} ${inputname}"
done

if [ "${trace}" = "yes" ]; then
    echo "GEOJSON_LIST=${GEOJSON_LIST}"  
fi;

tippecanoe -v

LAYER=mylayer

#i=0
i=16
while [ "$i" -le 18 ]; do
  
  if [ "${trace}" = "yes" ]; then
    echo "loop=$i"
  fi;

  RENDER_ZOOM="-Z$i -z$i --drop-densest-as-needed"
  OUTPUT_FILENAME="${OUTER_FOLDER}/${SUBFOLDERCOLOR}_zoom_$i.mbtiles"
  if [ "${trace}" = "yes" ]; then
    echo "LOOP ENTER: ZOOM=${RENDER_ZOOM}, OUTPUT_FILENAME=${OUTPUT_FILENAME}, ${SUBFOLDERCOLOR}"
  fi;

  tippecanoe ${RENDER_ZOOM} -f -o ${OUTPUT_FILENAME} --quiet ${GEOJSON_LIST}
  
  if [ "${trace}" = "yes" ]; then
    echo ""
  fi;

  i=$(( i + 1 ))
done 

if [ "${trace}" = "yes" ]; then
  echo ""
  echo "show content of tiles folder (${OUTER_FOLDER})"
  ls $OUTER_FOLDER
fi

echo "Start upload to Azure Blob Container: ${OUTER_FOLDER} => [${CONTAINER}] ${SUBPATH_MBTILES}" 
azureblob upload --localdirectory $OUTER_FOLDER --connectionstring $STORAGE --container $CONTAINER --azuredirectory $SUBPATH_MBTILES --mask "*.mbtiles"
echo ""
echo "upload completed!"
