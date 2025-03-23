## Login into GHCR 

```
docker login ghcr.io
```

Give Github username and Token as password to login to ghcr


## Setup Container Registry Secret

Before deploying, you need to create a secret for pulling images from GitHub Container Registry:

```
kubectl create secret docker-registry github-container-registry \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_TOKEN \
  --docker-email=YOUR_EMAIL
```

# EKS Implementation

## Check the EKS Cluster access from the EC2 instance

After creating EKS Cluster through Terraform scipts, when we try to see the EKS Cluster nodes from the EC2 instance using kubectl, it does not show any resources.


    I gave "kubectl get nodes" command to see the Cluster nodes created.

![image](https://github.com/user-attachments/assets/1387b980-538f-4a05-93a1-bcd8db45ebb1)

* This is the error it throws. Because by default Kubectl will not know what is the EKS cluster.
* Kubectl depends on the file called 'KubeConfig'
* In the KubeConfig file we can provide the list of clusters present. All the information about the clusters is updated in this file.
* Using the 'context' in the KubeConfig' file, Kubectl understands to which clusters it is connected.
* We can modify the context and kubectl updates accordingly.


## Commands to check the Kube config

```
kubectl config view
kubectl config current-context               // shows the list of K8S clusters present and we can select which cluster/context should kubectl connect to
kubectl config use-context <context-name>      // kubectl connects to mentioned context. 
```

### Update KubeConfig with EKS Cluster Information.

```
aws eks update-kubeconfig --region us-east-1 --name <eks-cluster>
```

## Next Create Service Account

```
kubectl apply -f serviceaccount.yaml
kubectl get sa                               // Displays the service accounts
```

## Apply all the deployments

```
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

- All the services and deployments are created for all the microservices.

## Check the deployments, pods, services

```
kubectl get pods               // displays the pods created for all the microservices
kubectl get svc               // displays the services created for all the microservices
kubectl get deployments
kubectl get all
```
   
## Install ArgoCD

### Deploying ArgoCD as K8s manifest

https://argo-cd.readthedocs.io/en/stable/

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

- This will deploy ArgoCD components (server, repo server, application controller, Redis, etc.) into the argocd namespace.
- argocd-server : Is the User INterface of ArgoCD which hosts the Argocd

```
kubectl get pods -n argocd
kubectl get svc -n argocd                              // displays the  services of Argocd
```

- Change the type fromm ClusterIP to LoadBalancer. It will create LoadBalancer for ArgoCD
- Use the LB address to access the ArgoCD UI, and confirue it with github repo where k8s manifests are present.
- It continuously watches for the updated deployments and deploy it on to EKS cluster.

```
kubectl edit svc argocd-server -n argocd
```

## Steps Login to ArgoCD

We need to get argo secret to login to ArgoCD UI

```
kubectl get secrets -n argocd
kubectl edit secret argocd-initial-admin-secret -n argocd
echo password | base64 --decode            // displays the password for argocd Login
```

## Login to ArgoCD UI 

- Login and Create Application
- We can see all the K8s resources getting deployed, pods, replica sets, deployments, service, ingress
- Now we can verify how the application is running in all the pods

```
kubectl get pods
kubectl get svc
kubectl edit svc <application-service-name>                
```

- Edit Type to LoadBalancer from CLusterID. 
- Now the application can be access using LB address

# Creating Application Load Balancer for App - Ingress.yaml

- I am deploying an application, a Tic-Tac-Toe app on Amazon EKS (Elastic Kubernetes Service) and wanted to expose it externally using an Application Load Balancer (ALB) via the AWS ALB Ingress Controller.

## Steps to achieve this

## OIDC Connector:
- ALB controller is deployed inside the EKS cluster, as a pod running inside it.
- It creates Elastic Load Balancer. But how can ALB controller deployed inside EKS cluster , can create a resource(ELB) within AWS. 
- To create any resource in AWS, we need to assign IAM role to the service account of ALB Contoller which want to perform this action,  and IAM policy with certain permissions should be attached to it.
- The ALB controller pod inside the cluster has the Service Account, this service account should be binded to IAM role and policy to create ELB in AWS. 
- This binding is provided by IAM OIDC Provider. We will connect service account with IAM role with IAM OIDC Provider.

## Setup OIDC Connector

### Commands to configure IAM OIDC provider

```
export cluster_name=<eks-cluster-name>
```

- Get EKS cluster OIDC ID
 
```
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5) 
echo $oidc_id                       // OIDC ID is stored in "oidc_id" variable.
```

- Associate OIDC provider with the cluster. Adding OIDC provider to the cluster

```
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
```

## Next steps

### 1. Create a IAM policy with permissions to create ELB in AWS.

#### Download IAM policy 

```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
```

#### Create the IAM policy with all the permissions to ELB

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

### 2. Create IAM role, attach that to the service account of ALB controller

#### Create IAM role

This creates the iam service account for ALB controller and maps it with the IAM role "AmazonEKSLoadBalancerControllerRole"

```
eksctl create iamserviceaccount \
  --cluster=<your-cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

## Install Helm 

- Installing Helm, so that I can install ALB Controller using Helm

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### Add helm repo for EKS

```
helm repo add eks https://aws.github.io/eks-charts
```

#### Update the repo

```
helm repo update eks
```

### Install ALB Controller through Helm

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \            
  -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<region> \
  --set vpcId=<your-vpc-id>
```

Check if the ALB controller containers are running
```
kubectl get pods -n kube-system
```

So till now I have done these steps

* Installed the AWS Load Balancer Controller using Helm.

* Configured IAM Roles and Service Account with appropriate permissions using OIDC.

* Ensured that the controller is running inside the EKS cluster and can create/manage ALBs in AWS.

## Create Kubernetes Ingress Resource

- Made sure the application was running with a Kubernetes Service of type ClusterIP (which is fine since ALB will forward traffic to it).
- Both the application "service" and the ingress should be deployed in same namespace, to route traffic to it properly. In this case its "default"


```
kubectl apply -f ingress.yaml
```

```
kubectl describe ingress tic-tac-toe-ingress -n default               // get the Load balancer address
```
- Now ingress resource us created and Application Load Balancer is also created for the app.
- I am able to access application through ALB address



![image](https://github.com/user-attachments/assets/0a84ae61-a01c-467a-a58d-432611a633d5)

## Argo CD

![image](https://github.com/user-attachments/assets/abaf1f1b-d8d5-4924-81d3-69851fe1176b)


![image](https://github.com/user-attachments/assets/02900832-0618-43ad-aa67-aae7984e7a88)

