#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: "
    echo "  ${0} <image_tag>"
fi

###################################################
#### **** Container package information ****
###################################################
MY_IP=`ip route get 1|awk '{print$NF;exit;}'`
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag=${1:-"openkbs/${DOCKER_IMAGE_REPO}"}
#PACKAGE=`echo ${imageTag##*/}|tr "/\-: " "_"`
PACKAGE="${imageTag##*/}"
baseDataFolder="$HOME/data-docker"

###################################################
#### ---- Volumes to be mapped (change this!) -----
#################################################### (examples - some local vars)
# (examples)
# IDEA_PRODUCT_NAME="IdeaIC2017"
# IDEA_PRODUCT_VERSION="3"
# IDEA_INSTALL_DIR="${IDEA_PRODUCT_NAME}.${IDEA_PRODUCT_VERSION}"
# IDEA_CONFIG_DIR=".${IDEA_PRODUCT_NAME}.${IDEA_PRODUCT_VERSION}"
# IDEA_PROJECT_DIR="IdeaProjects"
# VOLUMES="${IDEA_CONFIG_DIR} ${IDEA_PROJECT_DIR}"

# ---------------------------
# MANDATORY Variable: VOLUMES
# ---------------------------
VOLUMES="/graphdb-data"

# ---------------------------
# OPTIONAL Variable: PORT PAIR
# ---------------------------
#### Input: PORT - list of PORT to be mapped
# (examples)
GRAPHDB_PORT=7200
PORT_MAPPING_LIST="${GRAPHDB_PORT}:${GRAPHDB_PORT}"

#########################################################################################################
######################## DON'T CHANGE LINES STARTING BELOW (unless you need to) #########################
#########################################################################################################
LOCAL_VOLUME_DIR="${baseDataFolder}/${PACKAGE}"
DOCKER_VOLUME_DIR="/home/developer"

###################################################
#### ---- Function: Generate volume mappings  ----
####      (Don't change!)
###################################################
VOLUME_MAP=""
#### Input: VOLUMES - list of volumes to be mapped
function generateVolumeMapping() {
    for vol in $VOLUMES; do
        #echo "$vol"
        if [[ $vol == "/"* ]]; then
            # -- non-default /home/developer path; then use the full absolute path --
            VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}$vol:$vol"
        else
            # -- default sub-directory (without prefix absolute path) --
            VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/$vol:${DOCKER_VOLUME_DIR}/$vol"
        fi
        mkdir -p ${LOCAL_VOLUME_DIR}/$vol
        ls -al ${LOCAL_VOLUME_DIR}/$vol
    done
}
#### ---- Generate Volumes Mapping ----
generateVolumeMapping
echo ${VOLUME_MAP}

###################################################
#### ---- Function: Generate port mappings  ----
####      (Don't change!)
###################################################
PORT_MAP=""
function generatePortMapping() {
    for pp in $PORT_MAPPING_LIST; do
        #echo "$pp"
        port_pair=`echo $pp |  tr -d ' ' `
        if [ ! "$port_pair" == "" ]; then
            # -p ${local_dockerPort1}:${dockerPort1} 
            host_port=`echo $port_pair | tr -d ' ' | cut -d':' -f1`
            docker_port=`echo $port_pair | tr -d ' ' | cut -d':' -f2`
            PORT_MAP="${PORT_MAP} -p ${host_port}:${docker_port}"
        fi
    done
}
#### ---- Generate Port Mapping ----
generatePortMapping
echo ${PORT_MAP}

###################################################
#### ---- Mostly, you don't need change below ----
###################################################

#instanceName=my-${1:-${imageTag%/*}}_$RANDOM
#instanceName=my-${1:-${imageTag##*/}}
## -- transform '-' and space to '_' 
#instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/\-: " "_"`
instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/: " "_"`

echo "---------------------------------------------"
echo "---- Starting a Container for ${imageTag}"
echo "---------------------------------------------"
DISPLAY=${MY_IP}:0 \
docker run --rm \
    -d \
    --name=${instanceName} \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    ${VOLUME_MAP} \
    ${PORT_MAP} \
    ${imageTag}

echo ">>> Docker Status"
docker ps -a | grep "${instanceName}"
echo "-----------------------------------------------"
echo ">>> Docker Shell into Container `docker ps -lqa`"
echo "docker exec -it ${instanceName} /bin/bash"

##################################################
#### ---- Display IP:Port URL ----
##################################################
function displayPortainerURL() {
    port=${1}
    echo "... Go to: http://${MY_IP}:${port}"
    #firefox http://${MY_IP}:${port} &
    if [ "`which google-chrome`" != "" ]; then
        /usr/bin/google-chrome http://${MY_IP}:${port} &
    else
        firefox http://${MY_IP}:${port} &
    fi
}

#### ---- Wait a bit to allow GraphDb to start ----
sleep 8
displayPortainerURL ${GRAPHDB_PORT}
