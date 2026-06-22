pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1' 
    }
    stages {
        stage('Initialize & Validate') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Build Blueprint Plan') {
            steps {
                sh 'terraform plan -out=awsplan'
            }
        }
        stage('Deploy Infrastructure') {
            steps {
                sh 'terraform apply -auto-approve awsplan'
            }
        }
    }
}
