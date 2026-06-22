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

        stage('Deploy Infrastructure') {
            steps {
                // Cleaning local workspace cache files guarantees backend sync
                sh """
                    rm -rf .terraform*
                    terraform init -input=false
                    terraform apply -auto-approve -var='bucket_prefix=${params.BUCKET_PREFIX}' -var='aws_region=${params.AWS_REGION}'
                """
            }
        }
    }
}
