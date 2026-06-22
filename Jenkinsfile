pipeline {
    agent any
    
    parameters {
        string(name: 'BUCKET_PREFIX', defaultValue: 'redya-automation-', description: 'Prefix for the S3 tracking bucket')
        choice(name: 'AWS_REGION', choices: ['us-east-1', 'us-west-2'], description: 'Target AWS deployment region')
    }

    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
        // Captures branch name (e.g., 'dev' or 'main')
        ENV_NAME = "${env.BRANCH_NAME ?: 'dev'}" 
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                sh """
                    rm -rf .terraform .terraform.lock.hcl
                    terraform init -input=false
                    
                    # Automatically select or create an environment isolation workspace
                    terraform workspace select ${ENV_NAME} || terraform workspace new ${ENV_NAME}
                    
                    # Deploy changes safely isolated inside that workspace state block
                    terraform apply -auto-approve \
                      -var='bucket_prefix=${params.BUCKET_PREFIX}${ENV_NAME}-' \
                      -var='aws_region=${params.AWS_REGION}'
                """
            }
        }
    }
}
