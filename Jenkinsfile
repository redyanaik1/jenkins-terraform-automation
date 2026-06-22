pipeline {
    agent any
    
    parameters {
        string(name: 'BUCKET_PREFIX', defaultValue: 'redya-automation-', description: 'Prefix for the S3 tracking bucket')
        choice(name: 'AWS_REGION', choices: ['us-east-1', 'us-west-2'], description: 'Target AWS deployment region')
    }

    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
        // Replace '/' with '-' to ensure the workspace name is URL-safe for Terraform
        ENV_NAME = "${env.BRANCH_NAME.replace('/', '-')}" 
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Plan & Security Audit') {
            steps {
                sh """
                    # Clean up previous runs
                    rm -rf .terraform .terraform.lock.hcl tfplan tfplan.json
                    
                    # Initialize and select workspace
                    terraform init -input=false
                    terraform workspace select ${ENV_NAME} || terraform workspace new ${ENV_NAME}
                    
                    # 1. Generate a Plan file
                    terraform plan -out=tfplan -var='bucket_prefix=${params.BUCKET_PREFIX}${ENV_NAME}-' -var='aws_region=${params.AWS_REGION}'
                    
                    # 2. Automated Security Export
                    terraform show -json tfplan > tfplan.json
                """
            }
        }
        
        stage('Manual Approval') {
            steps {
                // Jenkins will pause here and wait for you to click "Proceed" in the UI
                input message: 'Do you want to apply this Terraform Plan?', ok: 'Apply Now'
            }
        }

        stage('Apply') {
            steps {
                // Apply the exact plan generated in the previous stage
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
    
    post {
        always {
            // Clean up the plan files after the job finishes to save space
            sh 'rm -f tfplan tfplan.json'
        }
    }
}
