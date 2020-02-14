@@echo
set image="tippecanoe-net:latest"
cd %~dp0
docker run --env STORAGE="%STORAGE_MSSDEV%" --env CONTAINER=staging --env SUBPATH_GEOJSON="geojson/dev" --env SUBPATH_MBTILES="mbtiles/twofiles" %image% 
pause

