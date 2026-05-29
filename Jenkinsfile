pipeline {
  agent {
    label 'terraform'
  }

  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  environment {
    TF_DIR = "terraform/environments/dev"
  }

  stages {

    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/rohitarame/jenkins-pipeline.git', branch: 'terraform-v2'
      }
    }

    stage('Terraform Version') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-credentials',
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh 'terraform version'
          sh 'aws --version'
          sh 'aws s3 ls'
        }
      }
    }

    stage('Terraform Init') {
      steps {
        dir("${env.TF_DIR}") {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-credentials',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]) {
            sh 'terraform init -input=false'
          }
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir("${env.TF_DIR}") {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-credentials',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]) {
            sh 'terraform plan -input=false -out=tfplan'
          }
        }
      }
    }

    stage('Manual Approval') {
      steps {
        input message: "Review the Terraform Plan log above. Apply to dev?", ok: 'Apply'
      }
    }

    stage('Terraform Apply') {
      steps {
        dir("${env.TF_DIR}") {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-credentials',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]) {
            sh 'terraform apply -input=false -auto-approve tfplan'
          }
        }
      }
    }
  }

  post {
    success {
      echo "SUCCESS: dev infrastructure deployed from branch terraform-v2."
      echo "Next: aws eks update-kubeconfig --region ap-south-1 --name cdec-dev-eks"
    }

    failure {
      echo 'FAILURE: Pipeline failed. Check the failed stage log.'
    }

    always {
      echo 'Build finished. Cleaning workspace...'
      deleteDir()
    }
  }
}
