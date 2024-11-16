pipeline {
    agent any
    environment{
        DOCKERHUB_CREDENTIALS_PSW = credentials('dockerhub-password')
        DOCKERHUB_CREDENTIALS_USR = credentials('dockerhub-username')
        BRANCH_NAME = ''
        COMMIT_ID = ''
    }
    stages {
        stage('git_checkout') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/s11mani/sample-java-app.git'
                    env.COMMIT_ID = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    env.BRANCH_NAME = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                }
            }
        }
        stage('unit_tests') {
            steps {
                sh '''
                mvn test
                '''
            }
        }
        stage('static_code_analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube-api') {
                        sh 'mvn clean install sonar:sonar'
                    }
                }
            }
        }
        stage('quality_gate_check') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube-api'
                }
            }
        }
        stage('maven_build') {
            steps {
                sh '''
                mvn clean install
                '''
            }
        }
        stage('docker_login_build_push') {
            steps {
                script {
                    // Ensure BRANCH_NAME and COMMIT_ID are not empty
                    if (!env.BRANCH_NAME) {
                        error "BRANCH_NAME is empty, cannot proceed with Docker build"
                    }
                    if (!env.COMMIT_ID) {
                        error "COMMIT_ID is empty, cannot proceed with Docker build"
                    }
                    
                    sh '''
                    # Use bash explicitly for variable substitution
                    #!/bin/bash
                    echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                    echo 'Login Completed'
                    
                    # Ensure that both variables are included in the tag
                    docker build -t ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID} .
                    docker tag ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID} ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest
                    docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID}
                    docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest
                    '''
                }
            }
        }
    }
}
