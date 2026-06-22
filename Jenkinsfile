pipeline {
    agent any
    
    parameters {
        string(name: 'BUCKET_PREFIX', defaultValue: 'redya-automation-', description: 'Prefix for the S3 tracking bucket')
        choice(name: 'AWS_REGION', choices: ['us-east-1', 'us-west-2'], description: 'Target AWS deployment region')
    }

    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
        // Replace '/' with '-' and truncate to 10 chars to ensure S3 bucket name < 37 chars
        ENV_NAME = "${env.BRANCH_NAME.replace('/', '-').take(10)}" 
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
                    
                    # Generate a Plan file
                    terraform plan -out=tfplan -var='bucket_prefix=${params.BUCKET_PREFIX}${ENV_NAME}-' -var='aws_region=${params.AWS_REGION}'
                    
                    # Automated Security Export
                    terraform show -json tfplan > tfplan.json
                """
            }
        }
        
        stage('Manual Approval') {
            steps {
                input message: 'Do you want to apply this Terraform Plan?', ok: 'Apply Now'
            }
        }

        stage('Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Destroy Infrastructure') {
            steps {
                input message: 'Are you sure you want to DESTROY all infrastructure?', ok: 'Destroy Now'
                sh 'terraform destroy -auto-approve -var="bucket_prefix=${params.BUCKET_PREFIX}${ENV_NAME}-" -var="aws_region=${params.AWS_REGION}"'
            }
        }
    }
    
    post {
        always {
            sh 'rm -f tfplan tfplan.json'
        }
    }
}
