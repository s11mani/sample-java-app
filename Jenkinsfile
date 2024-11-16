pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS_PSW = credentials('dockerhub-password')
        DOCKERHUB_CREDENTIALS_USR = credentials('dockerhub-username')
        // Declare variables globally so they are accessible in all stages
        BRANCH_NAME = ''
        COMMIT_ID = ''
    }
    stages {
        stage('git_checkout') {
            steps {
                script {
                    // Checkout the repository
                    echo 'Checking out the repository...'
                    git branch: 'main', url: 'https://github.com/s11mani/sample-java-app.git'

                    // Fetch the commit ID and branch name and set them as environment variables
                    echo 'Fetching commit ID and branch name...'
                    env.COMMIT_ID = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    env.BRANCH_NAME = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    // Debug: Print the values to ensure they are correct
                    echo "Commit ID: ${env.COMMIT_ID}"
                    echo "Branch Name: ${env.BRANCH_NAME}"

                    // Ensure default values if the variables are empty
                    if (!env.BRANCH_NAME || !env.COMMIT_ID) {
                        error "BRANCH_NAME or COMMIT_ID is empty, cannot proceed"
                    }
                }
            }
        }
        stage('unit_tests') {
            steps {
                sh 'mvn test'
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
                sh 'mvn clean install'
            }
        }
        stage('docker_login_build_push') {
            steps {
                script {
                    // Ensure BRANCH_NAME and COMMIT_ID are not empty before proceeding
                    if (!env.BRANCH_NAME || !env.COMMIT_ID) {
                        error "BRANCH_NAME or COMMIT_ID is empty, cannot proceed with Docker build"
                    }

                    echo "Proceeding with Docker build using ${env.BRANCH_NAME} and ${env.COMMIT_ID}"

                    // Docker login and build
                    sh '''
                    echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                    echo 'Login Completed'

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
