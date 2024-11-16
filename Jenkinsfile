pipeline {
    agent any
    environment{
        DOCKERHUB_CREDENTIALS_PSW = 'dockerhub-password'
        DOCKERHUB_CREDENTIALS_USR = 'dockerhub-username'
    }
    stages {
        stage('git_checkout') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/s11mani/sample-java-app.git'
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
                sh '''
                echo ${DOCKERHUB_CREDENTIALS_PSW} | sudo docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
	            echo 'Login Completed'
                '''
            }
        }
    }
}