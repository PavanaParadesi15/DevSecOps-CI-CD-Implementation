# Traffic Flow to Application (High-Level Overview) - Tic-Tac-Toe

```
[User's Browser]
       ↓
[ALB (Application Load Balancer)]
       ↓
[AWS Load Balancer Controller (Ingress)]
       ↓
[Kubernetes Service (ClusterIP)]
       ↓
[Kubernetes Pods (Tic-Tac-Toe App)]
```

# Step-by-Step Traffic Flow Explanation

## 1. User Accesses the ALB DNS (from a browser)

- Visit the public ALB URL that was provisioned by the AWS Load Balancer Controller based on your Ingress resource. (http://<alb-dns-name>.us-east-1.elb.amazonaws.com)

## 2. AWS ALB Receives the Request

* The ALB is internet-facing (as specified in the Ingress annotation).
* It accepts incoming traffic on port 80 (HTTP), which is also configured in your Ingress.

## 3. ALB Forwards to the Ingress Controller

* The AWS Load Balancer Controller running inside the EKS cluster watches the Ingress resource.

* It registers Kubernetes service targets (type ip) with the ALB Target Group.

* The ALB forwards requests to the private IPs of EKS worker nodes, targeting the appropriate port.

## 4. Ingress Controller Routes to the Correct Service

* Based on your Ingress rules, the controller forwards traffic for / path to the service:
* This Service is of type ClusterIP, which forwards traffic to your app’s Pods.

## 5. Kubernetes Service Routes to Application Pods

- The tic-tac-toe service routes the traffic to one of the running Pods of your Tic-Tac-Toe application on port 80.

## 6. Application Responds → Response Sent Back to ALB → Then to User

* The app generates a response (like HTML, JS, etc.), which is routed back up the chain:
* From Pod → Service → Ingress → ALB → Internet → Browser.


Everything is working because the ALB was dynamically created based on your Kubernetes Ingress, and it's forwarding external HTTP traffic to your internal app via the Load Balancer Controller and Service.

- This is the way traffic is flowing
- Internet ---> LoadBalancer (ALB) ----> Ingress ----> Service (application) ----> forwards to Pods


![image](https://github.com/user-attachments/assets/02900832-0618-43ad-aa67-aae7984e7a88)

