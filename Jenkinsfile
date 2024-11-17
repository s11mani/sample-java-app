pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS_PSW = credentials('dockerhub-password')
        DOCKERHUB_CREDENTIALS_USR = credentials('dockerhub-username')
        GIT_TOKEN = credentials('git-token')
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
                    mvn clean package
                '''
            }
        }
        stage('docker_login_build_push') {
            steps {
                script {
                        sh '''
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        echo 'Login Completed'
                        docker build -t ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID} .
                        docker tag ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID} ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest
                        '''
                }
            }
        }
        stage('trivy_docker_image_scan') {
            steps {
                script{
                    sh '''
                    trivy image --severity CRITICAL,HIGH ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest > docker_image_vulnerability.txt
                    '''
                    archiveArtifacts artifacts: 'docker_image_vulnerability.txt', followSymlinks: false
                }
            }
        }
        stage('docker_push_image') {
            steps {
                script {
                        sh '''
                        docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID}
                        docker push ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest
                        '''
                }
            }
        }
        stage('docker_clean_images') {
            steps {
                sh '''
                    docker rmi -f ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-${COMMIT_ID}
                    docker rmi -f ${DOCKERHUB_CREDENTIALS_USR}/java-17-helloworld:${BRANCH_NAME}-latest
                '''
            }
        }
        stage('update_helm_values') {
            steps {
                sh '''
                    sed -i "s|tag: \".*\"|tag: \"${BRANCH_NAME}-${COMMIT_ID}\"|" helm-charts/${BRANCH_NAME}.yaml
                '''
            }
        }
        stage('argo_deploy') {
            steps {
                script {
                    sh '''
                    git config user.name "jenkins-bot"
                    git config user.email "jenkins@example.com"
                    '''
                    sh '''
                    git add helm-charts/${BRANCH_NAME}.yaml
                    git commit -m "jenkins-bot update helm ${BRANCH_NAME}-${COMMIT_ID}"
                    git push https://s11mani:${GIT_TOKEN}@github.com/s11mani/sample-java-app.git ${BRANCH_NAME}
                    '''
                }
            }
        }
    }
}