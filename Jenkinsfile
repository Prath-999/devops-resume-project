pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "prath999/notes-app" 
        
        DOCKERHUB_CREDS = credentials('dockerhub-creds') 
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image..."
                    // We tag it with the Jenkins build number for version control, and 'latest'
                    sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest ./"
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    echo "Logging into DockerHub..."
                    sh "echo ${DOCKERHUB_CREDS_PSW} | docker login -u ${DOCKERHUB_CREDS_USR} --password-stdin"
                    
                    echo "Pushing Images..."
                    sh "docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            environment {
                // This loads the kubeconfig file securely into the workspace
                KUBECONFIG_FILE = credentials('kubeconfig')
            }
            steps {
                script {
                    echo "Downloading kubectl tool..."
                    sh "curl -LO https://dl.k8s.io/release/v1.28.2/bin/linux/amd64/kubectl && chmod +x kubectl"
                    
                    echo "Applying Kubernetes Manifests..."
                    sh "./kubectl --kubeconfig=$KUBECONFIG_FILE apply -f k8s/mysql.yaml"
                    sh "./kubectl --kubeconfig=$KUBECONFIG_FILE apply -f k8s/app.yaml"
                    
                    echo "Updating App to new image version..."
                    sh "./kubectl --kubeconfig=$KUBECONFIG_FILE set image deployment/notes-app notes-app=${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                }
            }
        }
    }
}