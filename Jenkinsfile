#!/bin/bash

pipeline {
    agent {
        node {
            label params.SLAVE
        }
    }

    environment {
        bob2 = "./bob/bob"
        DOCKER_CREDS = credentials('armdocker-so-login')
        ARTIFACTORY_CREDS = credentials('artifactory-esoadm-login')
        HELM_CREDS = credentials('armhelm.so.login')
    }

    stages {
        stage('Configure') {
            steps {
                sh "git submodule add -f ssh://gerrit.ericsson.se:29418/adp-cicd/bob bob"
                sh "git submodule update --init --recursive"
                sh "git config submodule.bob.ignore all"
                configFileProvider([configFile(fileId: "${env.ARMDOCKER_CONFIG_FILE_NAME}", targetLocation: "${HOME}/.docker/config.json")]) { }
                configFileProvider([configFile(fileId: "${env.KUBECONFIG_FILE_NAME}", targetLocation: "${WORKSPACE}/.kube/config")]) { }
            }
        }

        stage('Precondition') {
            when {
                expression { params.K8_NAMESPACE == "" || params.KUBECONFIG_FILE_NAME == "" || params.ARMDOCKER_CONFIG_FILE_NAME == "" || params.SLAVE == "" }
            }
            steps {
                sh "echo 'one required field is empty' && exit 1"
            }
        }

        stage('Clean') {
            steps {
                sh "${bob2} -lq"
            }
        }

        stage('Build image') {
            steps {
                sh "${bob2} build"
            }
        }

        stage('Push image') {
            steps {
                sh "${bob2} push"
            }
        }

        stage('Helm install') {
            steps {
                sh "${bob2} helm-install"
            }
        }

        stage('Testsuite Execution') {
            steps {
                sh "${bob2} testsuite-execution"
            }
        }
    }
    post {
        always {
            sh "${bob2} helm-delete"
            cucumber 'nbitestsuite/conftest/*.json'
        }
    }
}