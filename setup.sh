#!/bin/bash

dataDir=${YOUR_DATA_DIR}
buildDir=${THIS_REPOSITORY}
    
function dockerRunOpenhab2()
{
    local DOCKER_DATA_DIR=${dataDir}/dockerdatadir
    local OH2_DATA_DIR=${DOCKER_DATA_DIR}/openhab2

    # Check & create dockerdatadir root folder
    if [ ! -d "${DOCKER_DATA_DIR}" ]; then
        echo 'Creating ${DOCKER_DATA_DIR} to store OpenHab2 Data...'
        mkdir -m 777 ${DOCKER_DATA_DIR}
    fi
    # Check & create dockerdir-openhab2 root folder
    if [ ! -d "${OH2_DATA_DIR}" ]; then
        echo 'Creating ${OH2_DATA_DIR} to store OpenHab2 Data...'
        mkdir -m 777 ${OH2_DATA_DIR}
    fi
    # Check & copy openhab2 configuration
    if [ ! -d "${OH2_DATA_DIR}/conf" ]; then
        cp -rf ${dataDir}/openhab2-configurations/* ${OH2_DATA_DIR}/
        chmod -R 777 ${OH2_DATA_DIR}/*
    fi

    if [ -z "${1}" ]; then
        docker run -d -p 8080:8080 -p 8443:8443 \
            -v ${dataDir}/dockerdatadir/openhab2/conf:/usr/openhab-2.0/conf \
            -v ${dataDir}/dockerdatadir/openhab2/addons:/usr/openhab-2.0/addons \
            -v ${dataDir}/dockerdatadir/openhab2/userdata:/usr/openhab-2.0/userdata \
            -v ${dataDir}/dockerdatadir/openhab2/runtime/etc:/usr/openhab-2.0/runtime/etc \
            -v ${dataDir}/dockerdatadir/openhab2/runtime/karaf/etc:/usr/openhab-2.0/runtime/karaf/etc \
            --name openhab2 scripts_openhab:latest
    fi
}

function buildDocker()
{
    
    echo "Build Dir Is: ${buildDir}"
    # Step1.1: Download OpenHab ------------------------------------------------------------------------------
    echo "Prepare content for Openhab2 docker -----------------------------------------------------"
    cd ${buildDir}
    if [ ! -f "./openhab-offline-2.0.0-SNAPSHOT.zip" ]; then
        echo 'This is fresh system so downloading Openhab2 from internet'
        wget https://openhab.ci.cloudbees.com/job/openHAB-Distribution/lastSuccessfulBuild/artifact/distributions/openhab-offline/target/openhab-offline-2.0.0-SNAPSHOT.zip
    fi
    # Step1.2: Extract openhab
    if [ ! -d "./openhab-offline-2.0.0-SNAPSHOT" ]; then
        unzip openhab-offline-2.0.0-SNAPSHOT.zip -d openhab-offline-2.0.0-SNAPSHOT
        chmod 777 openhab-offline-2.0.0-SNAPSHOT
    fi
    
    # Step2: Moving configuration to source folder -----------------------------------------------------------
    if [ ! -d "${dataDir}/openhab2-configurations" ]; then
            # This folder will be moved to dockerdatadir in dockerRunOpenhab2 script
            mkdir -m 777 ${dataDir}/openhab2-configurations
            mkdir -m 777 ${dataDir}/openhab2-configurations/addons ${dataDir}/openhab2-configurations/runtime ${dataDir}/openhab2-configurations/runtime/etc ${dataDir}/openhab2-configurations/runtime/karaf ${dataDir}/openhab2-configurations/runtime/karaf/etc
            
            cp -rf ./openhab-offline-2.0.0-SNAPSHOT/conf ${dataDir}/openhab2-configurations/
            cp -rf ./openhab-offline-2.0.0-SNAPSHOT/userdata ${dataDir}/openhab2-configurations/
            cp -rf ./openhab-offline-2.0.0-SNAPSHOT/runtime/etc/* ${dataDir}/openhab2-configurations/runtime/etc/
            cp -rf ./openhab-offline-2.0.0-SNAPSHOT/runtime/karaf/etc/* ${dataDir}/openhab2-configurations/runtime/karaf/etc/
            
            echo 'Moving OpenHab2''s configuration outside container so it will be used in Docker''s volume'
        fi
    
    dockerRunOpenhab2 setup
}

buildDocker