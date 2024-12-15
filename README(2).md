
# **Coworking Space Service**

## **Overview**
The Coworking Space Service is a microservices-based application that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service includes an analytics API providing insights into user activity. It is containerized using Docker, deployed to Kubernetes on Amazon EKS, and integrated with CloudWatch for monitoring and logging.

---

## **Key Features**
- Microservices architecture.
- Analytics API for business insights.
- Secure database integration with environment variable management.
- Cloud-native deployment using Kubernetes on Amazon EKS.
- Real-time monitoring with CloudWatch Container Insights.

---

## **Setup Instructions**

### **1. Prerequisites**
- AWS CLI installed and configured.
- Docker installed.
- Kubernetes CLI (`kubectl`) installed and configured to connect to your EKS cluster.

### **2. Build and Push Docker Image**
1. Build the Docker image:
   ```bash
   docker build -t coworking-analytics .
   ```
2. Push the image to Amazon ECR:
   ```bash
   docker tag coworking-analytics:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/coworking-analytics:latest
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/coworking-analytics:latest
   ```

### **3. Deploy the Application**
1. Apply Kubernetes configuration files:
   ```bash
   kubectl apply -f configmap.yaml
   kubectl apply -f secret.yaml
   kubectl apply -f deployment.yaml
   ```
2. Verify deployment:
   ```bash
   kubectl get pods
   kubectl get svc
   ```

---

## **Endpoints**
- **Health Check**: Verifies the application’s health.
  ```bash
  curl http://<EXTERNAL_IP>:5153/health_check
  ```
- **Analytics**:
  - Daily usage report: `/api/reports/daily_usage`
  - User visit report: `/api/reports/user_visits`

---

## **Testing Instructions**
1. Ensure the application service has an external IP:
   ```bash
   kubectl get svc
   ```
2. Use `curl` to test endpoints or open in a browser:
   ```bash
   curl http://<EXTERNAL_IP>:5153/api/reports/daily_usage
   curl http://<EXTERNAL_IP>:5153/api/reports/user_visits
   ```

---

## **Monitoring and Logs**
- **CloudWatch Container Insights**:
  - Metrics: CPU, memory, and network usage.
  - Logs: Application logs for health checks and endpoint requests.
- Access logs in the **CloudWatch Logs Console** under:
  ```
  /aws/containerinsights/<CLUSTER_NAME>/application
  ```

---

## **Acknowledgments**
This project leverages:
- **Amazon EKS** for scalable Kubernetes deployments.
- **Amazon ECR** for container image storage.
- **CloudWatch** for robust monitoring and logging.

---
