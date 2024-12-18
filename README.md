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
   eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
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

