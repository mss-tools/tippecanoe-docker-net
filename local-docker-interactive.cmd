@@echo
set image="tippecanoe-net:latest"
cd %~dp0
docker run -it --entrypoint "/bin/bash" %image% 
pause

