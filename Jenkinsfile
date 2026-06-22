pipeline {
    agent any
    
    parameters {
        string(name: 'BUCKET_PREFIX', defaultValue: 'redya-prod-automation-', description: 'Custom prefix for the S3 bucket')
        choice(name: 'AWS_REGION', choices: ['us-east-1', 'us-west-2'], description: 'Target AWS Region')
    }

    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false -reconfigure -force-copy'
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                // We pass the Jenkins UI parameters directly into Terraform here!
                sh "terraform apply -auto-approve -var='bucket_prefix=${params.BUCKET_PREFIX}' -var='aws_region=${params.AWS_REGION}'"
            }
        }
    }
}
