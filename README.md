<h1>Rosyz CartOps – Single Tier E-Commerce Deployment on AWS</h1>

<p> <strong>Rosyz CartOps</strong> is a single-tier static e-commerce application built with HTML, CSS, and JavaScript, deployed on AWS using Docker and AWS DevOps services. This project demonstrates a real-world CI/CD workflow with secure credential handling and containerized deployment on EC2. </p> 

<hr/> <h2>Architecture Overview</h2>

<p><strong>Supporting Services:</strong></p> 

<ul> 
  <li>IAM (Roles & Permissions)</li> 
  <li>AWS Systems Manager (Parameter Store)</li>
  <li>EC2 Server</li>
  <li>Amazon S3 (Deployment Artifacts)</li> 
</ul> 

<hr/> <h2>Tech Stack</h2> <ul> <li><strong>Frontend:</strong> HTML, CSS, JavaScript</li> <li><strong>Containerization:</strong> Docker, Nginx</li> <li><strong>CI/CD:</strong> AWS CodePipeline, CodeBuild, CodeDeploy</li> <li><strong>Registry:</strong> Docker Hub</li> <li><strong>Compute:</strong> Amazon EC2 (Ubuntu)</li> <li><strong>Security:</strong> IAM, SSM Parameter Store</li> </ul> <hr/>

<h2>File Structure</h2>

    Rosyz-CartOps/
    │
    ├── index.html
    ├── style.css
    ├── script.js
    ├── Images/
    ├── futura.woff2
    │
    ├── Dockerfile
    ├── buildspec.yml
    ├── appspec.yml
    │
    └── scripts/
        ├── docker_installation.sh
        ├── stop_container.sh
        └── start_container.sh

<hr/>
<h2>Dockerfile</h2> 

    FROM nginx:alpine
    
    RUN rm -rf /usr/share/nginx/html/*
    
    COPY . /usr/share/nginx/html
    
    EXPOSE 80
    
    CMD ["nginx","-g","daemon off;"]

<hr/>
<h2>IAM Roles and Responsibilities</h2>
<h3>1. CodePipeline Service Role</h3> <ul> <li>Orchestrates Source → Build → Deploy</li> <li>Uses CodeStar Connections for GitHub</li> </ul> <h3>2. CodeBuild Service Role</h3> <ul> <li>Builds Docker image</li> <li>Pushes image to Docker Hub</li> <li>Reads secrets from SSM Parameter Store</li> </ul> <h3>3. CodeDeploy Service Role</h3> <ul> <li>Manages deployment lifecycle</li> <li>Executes lifecycle hooks on EC2</li> </ul> <h3>4. EC2 Instance Role (Critical)</h3> <ul> <li>Reads SSM parameters</li> <li>Downloads artifacts from S3</li> <li>Communicates with CodeDeploy agent</li> </ul> <hr/> 


<h2>Secure Secret Management (SSM Parameter Store)</h2>
<p>Docker Hub credentials are stored securely in AWS Systems Manager Parameter Store.</p> <table border="1" cellpadding="6"> <tr>
  
<th>Parameter Name</th> <th>Type</th> </tr> <tr> <td>/rosyz/docker/username</td> <td>String</td> </tr> <tr> <td>/rosyz/docker/password</td> <td>SecureString</td> </tr> <tr> <td>/rosyz/docker/registry</td> <td>docker.io</td> </tr> </table> <hr/>


<h2>buildspec.yml (AWS CodeBuild)</h2>

    version: 0.2
    
    env:
      parameter-store:
        DOCKER_REGISTRY_USERNAME: /rosyz/docker/username
        DOCKER_REGISTRY_PASSWORD: /rosyz/docker/password
        DOCKER_REGISTRY_URL: /rosyz/docker/registry
    
    phases:
      install:
        commands:
          - echo "Install phase started"
          - docker --version
    
      pre_build:
        commands:
          - echo "Logging in to Docker Registry..."
          - echo "$DOCKER_REGISTRY_PASSWORD" | docker login -u "$DOCKER_REGISTRY_USERNAME" --password-stdin "$DOCKER_REGISTRY_URL"
          - IMAGE_REPO_NAME="rosyz-cartops"
          - IMAGE_NAME="$DOCKER_REGISTRY_USERNAME/$IMAGE_REPO_NAME"
    
      build:
        commands:
          - echo "Build started on $(date)"
          - echo "Building Docker image..."
          - docker build -t $IMAGE_NAME:latest .
    
      post_build:
        commands:
          - echo "Pushing Docker image..."
          - docker push $IMAGE_NAME:latest
          - echo "Creating deployment artifact..."
          - zip -r rosyz-cartops.zip .
          - echo "Build completed on $(date)"
    
    artifacts:
      files:
        - rosyz-cartops.zip
        - appspec.yml
        - scripts/**/*
      discard-paths: no

<h2>appspec.yml (AWS CodeDeploy)</h2> 

    version: 0.0
    os: linux
    
    files:
      - source: /
        destination: /home/ubuntu/rosyz-cartops
        overwrite: true
    
    file_exists_behavior: OVERWRITE
    
    hooks:
      ApplicationStop:
        - location: scripts/stop_container.sh
          timeout: 300
          runas: root
    
      ApplicationStart:
        - location: scripts/start_container.sh
          timeout: 300
          runas: root

<h2>Deployment Scripts</h2>

<h3>stop_container.sh</h3>

    #!/bin/bash
    echo "Stopping existing container..."
    
    docker stop rosyz-cartops || true
    docker rm rosyz-cartops || true

<h3>start_container.sh</h3> 

    #!/bin/bash
    set -e
    
    IMAGE_NAME="priyanshusingh10114/rosyz-cartops:latest"
    CONTAINER_NAME="rosyz-cartops"
    
    echo "Fetching Docker Hub credentials from SSM..."
    
    DOCKER_USER=$(aws ssm get-parameter \
      --name /rosyz/docker/username \
      --query Parameter.Value \
      --output text)
    
    DOCKER_PASS=$(aws ssm get-parameter \
      --with-decryption \
      --name /rosyz/docker/password \
      --query Parameter.Value \
      --output text)
    
    if [ -z "$DOCKER_USER" ] || [ -z "$DOCKER_PASS" ]; then
      echo "Docker Hub credentials are missing"
      exit 1
    fi
    
    echo "Logging in to Docker Hub..."
    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
    
    echo "Pulling image: $IMAGE_NAME"
    docker pull $IMAGE_NAME
    
    echo "Stopping old container if exists..."
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true
    
    echo "Starting new container..."
    docker run -d \
      --name $CONTAINER_NAME \
      -p 80:80 \
      $IMAGE_NAME

<h2>EC2 Setup (Target Server)</h2>

<h3>Step 1: Launch EC2</h3> 

<ul> <li>AMI: Ubuntu 22.04 LTS</li> <li>Instance type: t2.micro</li> <li>Storage: 10 GB</li> </ul> <h3>Step 2: Security Group</h3> <ul> <li>Allow SSH (22) from your IP</li> <li>Allow HTTP (80) from 0.0.0.0/0</li> </ul>

<h4>After launching connect instance with ssh with local command prompt using .pem key</h4>

    sudo apt get update 

    sudo apt install docker.io -y

    sudo apt install nginx

<p>Installing Docker and Docker Compose</p>

    chmod +x docker_installation.sh
    ./docker_installation.sh
    sudo usermod -aG docker $USER
    sudo systemctl start docker



    


<h2>Key Problems Solved</h2> 
<ul> <li>IAM AssumeRole errors across services</li> <li>CodeDeploy stuck deployments</li> <li>SSM-based secure credential handling</li> <li>Docker Hub authentication during deployment</li> <li>CodeStar Connection authorization issues</li> </ul> <hr/> 

<h2>Final Outcome</h2> <ul> <li>Docker image successfully built and pushed</li> <li>EC2 pulls the latest image from Docker Hub</li> <li>Nginx serves the e-commerce application</li> <li>Deployment completes successfully</li> </ul> <hr/> 

<h2>Author</h2>
<p> <strong>Priyanshu Singh</strong><br/> DevOps | AWS | Docker | Cloud </p>
