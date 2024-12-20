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
                        docker build -t ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-${COMMIT_ID} .
                        docker tag ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-${COMMIT_ID} ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-latest
                        '''
                }
            }
        }
        stage('trivy_docker_image_scan') {
            steps {
                script{
                    sh '''
                    trivy image --format table --severity CRITICAL,HIGH ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-latest > docker_image_vulnerability.html
                    '''
                    archiveArtifacts artifacts: 'docker_image_vulnerability.html', followSymlinks: false
                }
            }
        }
        stage('docker_push_image') {
            steps {
                script {
                        sh '''
                        docker push ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-${COMMIT_ID}
                        docker push ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-latest
                        '''
                }
            }
        }
        stage('docker_clean_images') {
            steps {
                sh '''
                    docker rmi -f ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-${COMMIT_ID}
                    docker rmi -f ${DOCKERHUB_CREDENTIALS_USR}/spring-petclinic:${BRANCH_NAME}-latest
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
                    git add helm-charts/${BRANCH_NAME}.yaml
                    git commit -m "jenkins-bot update helm ${BRANCH_NAME}-${COMMIT_ID}"
                    '''
                    def maxRetries = 5
                    def retries = 0
                    def pushSuccess = false
                    while (retries < maxRetries && !pushSuccess) {
                        try {
                            sh '''
                            git push https://s11mani:${GIT_TOKEN}@github.com/s11mani/sample-java-app.git ${BRANCH_NAME}
                            '''
                            pushSuccess = true  // Break the loop if the push is successful
                        } catch (Exception e) {
                            retries++
                            echo "Push failed, retrying... Attempt ${retries} of ${maxRetries}"
                            try {
                                sh 'git pull --rebase origin ${BRANCH_NAME}'
                            } catch (mergeError) {
                                echo "Merge failed, retrying push after resolving conflict..."
                            }
                        }
                    }    
                }
            }
        }
    }
    post {
    always {
        script {
            // Define variables
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

            // Create HTML email body
            def body = """
                <html>
                    <body>
                        <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                            <h2>${jobName} - Build ${buildNumber}</h2>
                            <div style="background-color: ${bannerColor}; padding: 10px;">
                                <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                            </div>
                            <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                        </div>
                    </body>
                </html>
            """

            // Send email with the generated body
            emailext(
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'sabbanimanideep@gmail.com',
                from: 'jenkins@example.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html',
                attachmentsPattern: 'docker_image_vulnerability.html'
                )
            }
        }
    }
}