# Coworking Space Service – Analytics API

The Coworking Space Service is a microservices-based platform designed to manage coworking spaces, track user activities, and provide actionable business insights. This repository focuses on the Analytics API, which provides data analysis endpoints for business analysts. By integrating with a PostgreSQL database and leveraging Kubernetes (via Amazon EKS) for container orchestration, this API offers scalable, reliable analytics capabilities.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [Architecture](#architecture)
4. [Prerequisites](#prerequisites)
5. [Local Development and Testing](#local-development-and-testing)
   - [AWS Configuration](#aws-configuration)
   - [Kubernetes Cluster Setup](#kubernetes-cluster-setup)
   - [PostgreSQL Setup in Kubernetes](#postgresql-setup-in-kubernetes)
   - [Seeding the Database](#seeding-the-database)
   - [Running the Analytics Application Locally](#running-the-analytics-application-locally)
6. [Containerization & CI/CD](#containerization--cicd)
   - [Building & Testing the Docker Image](#building--testing-the-docker-image)
   - [Continuous Integration with AWS CodeBuild](#continuous-integration-with-aws-codebuild)
7. [Deployment to EKS](#deployment-to-eks)
   - [ConfigMaps & Secrets](#configmaps--secrets)
   - [Deployment Manifests](#deployment-manifests)
   - [Service & Load Balancing](#service--load-balancing)
   - [Verification & Testing in Production](#verification--testing-in-production)
8. [Maintenance & Cleanup](#maintenance--cleanup)
9. [Troubleshooting](#troubleshooting)
10. [References & Further Reading](#references--further-reading)
11. [License](#license)

## Project Overview

The Coworking Space Service enables flexible, on-demand usage of office spaces. By capturing real-time data on user check-ins, tokens requested, and visitor patterns, it empowers business analysts to make data-driven decisions.

This repository:

- Focuses on the Analytics API that queries user activity data from a PostgreSQL database.
- Provides daily usage, user visit reports, and other analytics endpoints.
- Demonstrates best practices in DevOps, microservices deployment, and CI/CD.

## Key Features

- **Microservice Architecture**: The analytics functionality is isolated and deployable as a standalone service.
- **Kubernetes & EKS**: Scalable deployment, rolling updates, and self-healing capabilities.
- **PostgreSQL Integration**: A persistent backend store for analytical data.
- **CI/CD Pipeline**: Automated build, test, and deployment using CodeBuild and ECR.
- **Configurable via ConfigMaps & Secrets**: Clear separation of sensitive and non-sensitive configuration.

## Prerequisites

- **AWS CLI**: Configure with credentials and correct IAM permissions (able to create EKS clusters, push to ECR, etc.).
- **kubectl & eksctl**: For Kubernetes cluster management and EKS provisioning.
- **Docker**: To build and test container images locally.
- **psql (PostgreSQL Client)**: For verifying database connectivity.
- **Python 3 & pip**: Required if you want to run and test the Analytics application locally before containerizing.
- **git**: For version control and integration with CodeBuild via GitHub.
- **IAM Permissions**: Ensure you have the necessary AWS IAM policies to manage EKS, ECR, and CodeBuild.

---

# Local Development and Testing

## AWS Configuration

Set up your AWS credentials:

```bash
aws configure
```

Provide the AWS Access Key, Secret Key, and default region (e.g., `us-east-1`). Test with:

```bash
aws sts get-caller-identity
```

---

## Kubernetes Cluster Setup

1. **Install `eksctl`**:  
   Follow the [eksctl installation instructions](https://eksctl.io/introduction/#installation).

2. **Create an EKS Cluster:**

   ```bash
   eksctl create cluster \
     --name my-cluster \
     --region us-east-1 \
     --nodegroup-name my-nodes \
     --node-type t3.small \
     --nodes 1 \
     --nodes-min 1 \
     --nodes-max 2
   ```

3. **Update kubeconfig:**

   ```bash
   aws eks --region us-east-1 update-kubeconfig --name my-cluster
   ```

4. **Verify Context:**

   ```bash
   kubectl config current-context
   ```

---

## PostgreSQL Setup in Kubernetes

1. **Apply PersistentVolumeClaim (PVC):**

   ```bash
   kubectl apply -f pvc.yaml
   ```

2. **Apply PersistentVolume (PV):**

   ```bash
   kubectl apply -f pv.yaml
   ```

   Ensure `storageClassName` and `accessModes` match between PV and PVC.

3. **Deploy PostgreSQL:**

   ```bash
   kubectl apply -f postgresql-deployment.yaml
   ```

4. **Create a Service for PostgreSQL:**

   ```bash
   kubectl apply -f postgresql-service.yaml
   ```

5. **Port-forward for Local Access:**

   ```bash
   kubectl port-forward service/postgresql-service 5433:5432 &
   ```

   PostgreSQL is now accessible at `127.0.0.1:5433`.

---

## Seeding the Database

1. **Install `psql`:**

   ```bash
   apt update && apt install -y postgresql postgresql-contrib
   ```

2. **Seed the Database:**

   ```bash
   export DB_PASSWORD=mypassword
   PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < seed_file.sql
   ```

   Repeat for all seed files as necessary. Verify tables and data using `\l` and `\dt` from within `psql`.

---

## Running the Analytics Application Locally

1. **Install Dependencies:**

   ```bash
   apt update && apt install -y build-essential libpq-dev
   pip install --upgrade pip setuptools wheel
   pip install -r analytics/requirements.txt
   ```

2. **Set Environment Variables & Run:**

   ```bash
   export DB_USERNAME=myuser
   export DB_PASSWORD=mypassword
   export DB_HOST=127.0.0.1
   export DB_PORT=5433
   export DB_NAME=mydatabase

   python analytics/app.py
   ```

3. **Test Endpoints:**

   ```bash
   curl http://127.0.0.1:5153/api/reports/daily_usage
   curl http://127.0.0.1:5153/api/reports/user_visits
   ```

---

## Containerization & CI/CD

### Building & Testing the Docker Image

1. **Write the Dockerfile** inside `analytics/`:

   - Use a lightweight Python base image (e.g., `python:3.9-slim`).
   - Install dependencies via `pip install -r requirements.txt`.
   - Set `ENTRYPOINT` and `CMD` as needed.

2. **Build the Image:**

   ```bash
   docker build -t coworking-analytics:local .
   ```

3. **Test the Image:**

   ```bash
   docker run --network="host" coworking-analytics:local
   curl http://127.0.0.1:5153/api/reports/daily_usage
   ```

   Ensure the local application is not running simultaneously on port `5153`.

---

### Continuous Integration with AWS CodeBuild

1. **Create an ECR Repository:**

   In the AWS Console, create an ECR repo named `coworking-analytics`.

2. **Set Up CodeBuild:**

   - Connect CodeBuild to your GitHub repository.
   - Provide IAM roles that allow `docker push` to ECR.

3. **Create `buildspec.yaml` with Steps to:**

   - Login to ECR using `aws ecr get-login-password`.
   - Build Docker image.
   - Tag image with `$CODEBUILD_BUILD_NUMBER`.
   - Push image to ECR.

4. **Trigger a Build:**

   Manually start a build in CodeBuild and verify the new image is in ECR.

---

## Deployment to EKS

### ConfigMaps & Secrets

1. **ConfigMap:** Store non-sensitive config (DB_HOST, DB_USERNAME, DB_PORT, DB_NAME):

   ```bash
   kubectl create configmap coworking-config \
     --from-literal=DB_HOST=postgresql-service \
     --from-literal=DB_USERNAME=myuser \
     --from-literal=DB_NAME=mydatabase \
     --from-literal=DB_PORT=5432
   ```

2. **Secret:** Store sensitive data (DB_PASSWORD):

   ```bash
   kubectl create secret generic coworking-secret \
     --from-literal=DB_PASSWORD=mypassword
   ```

### Deployment Manifests

Use a Deployment manifest referencing the ECR image built by CodeBuild:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: coworking
spec:
  type: LoadBalancer
  selector:
    service: coworking
  ports:
    - name: "5153"
      protocol: TCP
      port: 5153
      targetPort: 5153
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coworking
  labels:
    name: coworking
spec:
  replicas: 1
  selector:
    matchLabels:
      service: coworking
  template:
    metadata:
      labels:
        service: coworking
    spec:
      containers:
      - name: coworking
        image: <YOUR_ECR_URI_HERE>
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5153
        livenessProbe:
          httpGet:
            path: /health_check
            port: 5153
          initialDelaySeconds: 5
          timeoutSeconds: 2
        readinessProbe:
          httpGet:
            path: /readiness_check
            port: 5153
          initialDelaySeconds: 5
          timeoutSeconds: 5
        envFrom:
        - configMapRef:
            name: coworking-config
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: coworking-secret
              key: DB_PASSWORD
      restartPolicy: Always
```

Apply the manifest:

```bash
kubectl apply -f deployment.yaml
```

### Service & Load Balancing

The LoadBalancer-type Service will provide an external IP. Retrieve it with:

```bash
kubectl get svc
```

### Verification & Testing in Production

Once you have the External IP, test the endpoints:

```bash
curl http://<EXTERNAL-IP>:5153/api/reports/daily_usage
curl http://<EXTERNAL-IP>:5153/api/reports/user_visits
```

Verify data correctness and API responsiveness.

---

## Maintenance & Cleanup

1. **Deleting the EKS Cluster:**

   ```bash
   eksctl delete cluster --name my-cluster --region us-east-1
   ```

2. **Stopping Port-Forwarding:**

   ```bash
   ps aux | grep 'kubectl port-forward' | grep -v grep | awk '{print $2}' | xargs -r kill
   ```

3. **Removing AWS Resources:**

   Delete ECR repositories, CodeBuild projects, ConfigMaps, Secrets, and other infrastructure when no longer needed.
