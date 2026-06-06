# voiceowl-api

Minimal Node.js + Express API with MongoDB (Mongoose), tests and DevOps files.

Structure:
- src/: application source
- tests/: integration tests (Jest + supertest + mongodb-memory-server)
- k8s/: Kubernetes manifests
- .github/: GitHub Actions workflows

Usage:
1. Copy files to your repo.
2. Fill secrets (DockerHub, KUBE_CONFIG_DATA) in your CI provider.
3. Run locally: `docker-compose -f docker-compose.dev.yml up --build`
4. Run tests: `npm ci && npm test`

# Terraform
Used modules and created EKS cluster

# ALB controller
eksctl create iamserviceaccount \
  --cluster=<your-cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm repo add eks https://aws.github.io/eks-charts

helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<your-region> \
  --set vpcId=<your-vpc-id>

kubectl get deployment -n kube-system aws-load-balancer-controller

#
kubectl describe node <node-name> | egrep -A2 "Allocatable|Capacity"
kubectl top nodes
kubectl top pods -A

