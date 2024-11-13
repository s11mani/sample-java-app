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
        stage('tests_phase'){
            steps{
                sh '''
                mvn test
                '''
            }
        }
    }
}