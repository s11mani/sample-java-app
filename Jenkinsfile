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
                    
                    // Fetch commit ID and branch name using git commands
                    echo 'Fetching commit ID and branch name...'
                    def commitId = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    def branchName = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    // Debug: Print the values to ensure they are correct
                    echo "Commit ID: ${commitId}"
                    echo "Branch Name: ${branchName}"

                    // Set the environment variables for the next stage
                    env.COMMIT_ID = commitId
                    env.BRANCH_NAME = branchName

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
                script {
                    if (!env.BRANCH_NAME || !env.COMMIT_ID) {
                        error "BRANCH_NAME or COMMIT_ID is empty, cannot proceed with Docker build"
                    }
                    echo "Logging into Docker..."
                    sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                    echo 'Login Completed'

                    echo "Building and pushing Docker image..."
                    sh "docker build -t ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${env.BRANCH_NAME}-${env.COMMIT_ID} ."
                    sh "docker tag ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${env.BRANCH_NAME}-${env.COMMIT_ID} ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${env.BRANCH_NAME}-latest"
                    sh "docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${env.BRANCH_NAME}-${env.COMMIT_ID}"
                    sh "docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${env.BRANCH_NAME}-latest"
                }
            }
        }
    }
}
