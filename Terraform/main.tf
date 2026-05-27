provider "aws" {
  region = "eu-north-1"
}


resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Allow SSH and Jenkins web traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes NodePort range for Apps"
    from_port   = 30000
    to_port     = 32767
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


resource "aws_instance" "jenkins_server" {
  ami           = "ami-05d62b9bc5a6ca605"
  instance_type = "t3.small"
  key_name      = "DjangoCICD"

  tags = {
    Name = "Jenkins-CI-Server"
  }
}

resource "aws_instance" "k3s_server" {
  ami           = "ami-05d62b9bc5a6ca605"
  instance_type = "t3.small"
  key_name      = "DjangoCICD"

  tags = {
    Name = "K8s-Cluster-Node"
  }
}
