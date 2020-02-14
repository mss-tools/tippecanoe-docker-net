#!/bin/sh
set -e
echo ""
echo "Tippecanoe Runner CLI v1.0.4"
# SYNTAX
#$1...geoJson file filter sample: "/*.orange.geojson"
#$2...is the pure color name that can/should ne used for file or folder names!

echo ""
trace=yes
mainFolderPath=$(pwd)

OUTER_FOLDER=$mainFolderPath/data_tiles
#ex $1
FILTER=./splits/*.geojson
#ex S2
SUBFOLDERCOLOR=outdoor
#ex $3
FOLDER=$3

INNER_FOLDER="/data_tiles"
OUTPUTDIRNAME="$INNER_FOLDER/$SUBFOLDERCOLOR/";

if [ "${trace}" = "yes" ]; then
  echo "PWD=${mainFolderPath}"
  echo "STORAGE=${STORAGE}"
  echo "CONTAINER=${CONTAINER}"
  echo "SUBPATH_MBTILES=${SUBPATH_MBTILES}"
  echo "SUBPATH_GEOJSON=${SUBPATH_GEOJSON}"

  echo "FILTER=$FILTER"
  echo "OUTER_FOLDER=$OUTER_FOLDER"
  echo "INNER_FOLDER=$INNER_FOLDER"
  echo "OUTPUTDIRNAME=$OUTPUTDIRNAME"
  echo "FOLDER=$FOLDER"
fi

mkdir -p $OUTER_FOLDER
mkdir -p $OUTPUTDIRNAME

#azureblob download --localdirectory $BITBUCKET_CLONE_DIR/splits --connectionstring $STORAGE_MSSDEV --container $CONTAINER_PRODUCTION --azuredirectory $SUBPATH_GEOJSON_PRODUCTION --mask "*.geojson"
# ./cli-linux/docker-convert.sh "${BITBUCKET_CLONE_DIR}/splits/*.geojson" "outdoor" "${BITBUCKET_CLONE_DIR}/splits"

echo "Start download from Azure Blob Container [${CONTAINER}] ${SUBPATH_GEOJSON} => ./splits"
azureblob download --localdirectory ./splits --connectionstring $STORAGE --container $CONTAINER --azuredirectory $SUBPATH_GEOJSON --mask "*.geojson" --verbosity d
echo ""
echo "Download completed!"

GEOJSON_LIST=""
for f in $FILTER; do
  #echo $f
  b=$(basename $f)
  inputname="/splits/${b}"
  #echo "inputname: ${inputname}"
  GEOJSON_LIST="${GEOJSON_LIST} ${inputname}"
done

if [ "${trace}" = "yes" ]; then
    echo "GEOJSON_LIST=${GEOJSON_LIST}"  
fi;

LAYER=mylayer

i=0
while [ "$i" -le 18 ]; do
  #echo "loop=$i"
  RENDER_ZOOM="-Z$i -z$i --drop-densest-as-needed"
  OUTPUT_FILENAME="/data_tiles/$2_zoom_$i.mbtiles"
  #echo "LOOP ENTER: ZOOM=${RENDER_ZOOM}, OUTPUT_FILENAME=${OUTPUT_FILENAME}, $2"
  tippecanoe -v "$OUTER_FOLDER:$INNER_FOLDER" -v "$FOLDER:/splits"  $imageName -l ${LAYER} ${RENDER_ZOOM} -f -o ${OUTPUT_FILENAME} --quiet ${GEOJSON_LIST}
  #echo ""
  i=$(( i + 1 ))
done 

if [ "${trace}" = "yes" ]; then
  echo ""
  echo "show content of tiles folder"
  ls $OUTER_FOLDER
fi