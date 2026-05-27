provider "aws" {
  region = "eu-north-1"
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH and Jenkins web traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For production, change this to your specific IP
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Kubernetes (K3s) Node
resource "aws_security_group" "k3s_sg" {
  name        = "k8s-security-group"
  description = "Allow SSH, K8s API, and NodePort app access"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K3s API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins will use this port to deploy apps
  }

  ingress {
    description = "Kubernetes NodePort range for Apps"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This allows you to view your Notes app in the browser
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1. Jenkins Server
resource "aws_instance" "jenkins_server" {
  ami           = "ami-05d62b9bc5a6ca605"
  instance_type = "t3.small"
  key_name      = "DjangoCICD"

  tags = {
    Name = "Jenkins-CI-Server"
  }
}

# 2. Kubernetes (K3s) Cluster Server
resource "aws_instance" "k3s_server" {
  ami           = "ami-05d62b9bc5a6ca605"
  instance_type = "t3.small"
  key_name      = "DjangoCICD"

  tags = {
    Name = "K8s-Cluster-Node"
  }
}
