pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1' 
    }
    stages {
        stage('Initialize & Validate') {
            steps {
                // The flags tell Terraform to run completely unattended
                sh 'terraform init -input=false -reconfigure'
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
