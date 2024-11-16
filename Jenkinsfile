pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS_PSW = credentials('dockerhub-password')
        DOCKERHUB_CREDENTIALS_USR = credentials('dockerhub-username')
        BRANCH_NAME = ''
        COMMIT_ID = ''
    }
    stages {
        stage('git_checkout') {
            steps {
                script {
                    echo 'Checking out the repository...'
                    git branch: 'main', url: 'https://github.com/s11mani/sample-java-app.git'
                    
                    // Fetch the commit ID and branch name
                    echo 'Fetching commit ID and branch name...'
                    env.COMMIT_ID = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    env.BRANCH_NAME = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    // Debug: Print the values to ensure they are correct
                    echo "Commit ID: ${env.COMMIT_ID}"
                    echo "Branch Name: ${env.BRANCH_NAME}"

                    // Ensure the variables are not empty
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
                // Check if the environment variables are not empty before proceeding with Docker build
                sh '''
                if [ -z "${BRANCH_NAME}" ] || [ -z "${COMMIT_ID}" ]; then
                    echo "BRANCH_NAME or COMMIT_ID is empty, cannot proceed with Docker build"
                    exit 1
                fi
                
                echo "Logging into Docker..."
                echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                echo 'Login Completed'

                echo "Building and pushing Docker image..."
                docker build -t ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID} .
                docker tag ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID} ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest
                docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID}
                docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest
                '''
            }
        }
    }
}
