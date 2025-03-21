# Stages of GH Actions pipeline.

## CI Part

- Pipeline starts execution with the github Pull request. Github actions is triggered
- Within github workflows there are multiple workflows 

**1. Unit Testing** - Runs the test suite using Vitest

**2. Static Code Analysis** - We can find un-declared variables, un-invoked functions, deprecated packages can be found in the static code analysis. After this comes the  Build stage.

**3. Build** - Creates a production build of the application

**4. Docker Image Creation** - Builds a Docker image using a multi-stage Dockerfile

**5. Docker Image Scan** - Scans the image for vulnerabilities using Trivy

**6. Docker Image Push** - Pushes the image to GitHub Container Registry (GHCR)

**7. Update Kubernetes Deployment** - Updates the Kubernetes deployment file with the new image tag


## CD Part

- I am using ArgoCD a gitops tool. It detects the updated image tag whenever it is updated in the github K8S manifests and deploys the updated application image onto EKS cluster








