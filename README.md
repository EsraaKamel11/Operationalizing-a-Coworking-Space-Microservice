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
