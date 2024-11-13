pipeline{
    agent any
    stages{
        stage('git_checkout'){
            steps{
                script{
                    git branch: 'main', url: 'https://github.com/s11mani/sample-java-app.git'
                }
            }
        }
        stage('unit_tests'){
            steps{
                sh '''
                mvn test
                '''
            }
        }
        stage('static_code_analysis'){
            steps{
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube-api') {
                        sh 'mvn clean install sonar:sonar'
                    }
            }
        }
    }
}