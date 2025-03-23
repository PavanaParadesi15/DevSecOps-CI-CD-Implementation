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




![image](https://github.com/user-attachments/assets/0a84ae61-a01c-467a-a58d-432611a633d5)

