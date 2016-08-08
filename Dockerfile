###########################################
# Dockerfile to build OpenHAB2
###########################################
FROM dordoka/rpi-java8

MAINTAINER Thien Tran <thientran1986@gmail.com>
# Argument & Environment variables
LABEL com.example.image-specs="{\"Description\":\"OpenHab2 Container\",\"Usage\":\"docker run -d -p 8080:8080 iotfwk/openhab2:1.0\",\"Version\":\"1.0-beta\"}"

ENV APPDIR="/usr/openhab-2.0"  \
    PATH=${APPDIR}:${PATH}
# Create & Copy openhab from local
#mkdir -p ${APPDIR} && 

COPY openhab-offline-2.0.0-SNAPSHOT ${APPDIR}

WORKDIR ${APPDIR}

# Expose volume with configuration and userdata dir
VOLUME ${APPDIR}/conf ${APPDIR}/addons ${APPDIR}/userdata ${APPDIR}/runtime/etc ${APPDIR}/runtime/karaf/etc 

EXPOSE 8080 8443
CMD ${APPDIR}/start.sh

