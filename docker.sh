# The following command is for linux. For windows, see the comments in Dockerfile.win
 docker run -it --rm -u ${UID}:$(id -g) -v ${PWD}/../:/data -w /data jack-gcc:latest
#  docker run -it --rm -u 0 -v ${PWD}/../:/data -w /data jack-gcc:latest
