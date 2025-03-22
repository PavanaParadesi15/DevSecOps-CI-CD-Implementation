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



# ci.yaml Explanation

# Github actions pipeline
GH Actions has actions for every action available in documentation, actions are like plugins that can be used to perform a specific task.

## This pipeline has 4 jobs:

### 1. Test: Run unit tests
- runs-on : define the runner , either github provided or self-hosted runner
- steps: define the steps to be executed
- name: name of the step, checkout code, setup nodejs, install dependencies, run tests, 

### 2. Lint: Run static code analysis
- runs-on : define the runner , either github provided or self-hosted runner
- steps: define the steps to be executed, 
- name: name of the job, checkout code, setup nodejs, install dependencies, Run lint for static code analysis

### 3. Build: Build Docker image
- runs-on : define the runner , either github provided or self-hosted runner
- steps: define the steps to be executed,
- name: name of the job, needs: depends on previous steps(test, lint), checkout code, setup nodejs, install dependencies, build project.
- upload build artifacts to dist folder inside the github repo storage

### 4. Push: Build image, Scan Image and Push Docker image to GHCR
- runs-on : define the runner , either github provided or self-hosted runner
- steps: define the steps to be executed, 
- name: name of the job, needs: depends on previous steps(build), checkout code, download build artifacts,
- setup docker build, login to GHCR (ghcr.io), In GHCR, name of the registry is the same as the github username/repository name, need image ID and tag.
- We can push the image to container register (GHCR) using access token (personal access token). 
- Put the container registry URL and name into the environment variable.
- Login to container registry (GHCR) using access token
- Extract metadata for Docker image, tags for the Docker image. It should have 3 tags, branch name, version, github sha. Everytime image is generated, tag is unique.
- Next step is Build docker image, with the tags specified and the image name
- Then run trivy vulnerability scanner, for the Docker image, trivy is a vulnerability scanner for container images, it scans the image for vulnerabilities.
- Finally Push docker image to container registry (GHCR), using tags
- Set image tag output, to be used in the next job

### 5. Deploy: Deploy Docker image to Kubernetes
- runs-on : define the runner , either github provided or self-hosted runner
- steps: define the steps to be executed.

```
update-k8s:
  name: Update Kubernetes Deployment
  runs-on: ubuntu-latest
  needs: [docker]
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```
* name: Human-readable name of the job.

* runs-on: ubuntu-latest: Uses the latest Ubuntu runner.

* needs: [docker]: This job waits for a docker job to finish before it runs (likely where the Docker image is built and pushed).

* if: This job only runs on a push event to the main branch.


```
- name: Checkout code
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.TOKEN }}

```
* Checks out the repo code into the runner.

* Uses a custom token (stored as a secret) instead of the default GitHub token — likely needed to allow pushing changes back.

```
- name: Setup Git config
  run: |
    git config user.name "GitHub Actions"
    git config user.email "actions@github.com"
```

Configures Git identity so that commits can be made from the GitHub Actions bot.

```
- name: Update Kubernetes deployment file
  env:
    IMAGE_TAG: sha-${{ github.sha }}
    GITHUB_REPOSITORY: ${{ github.repository }}
    REGISTRY: ghcr.io
  run: |
    NEW_IMAGE="${REGISTRY}/${GITHUB_REPOSITORY}:${IMAGE_TAG}"
    
    sed -i "s|image: ${REGISTRY}/.*|image: ${NEW_IMAGE}|g" kubernetes/deployment.yaml
    
    echo "Updated deployment to use image: ${NEW_IMAGE}"
    grep -A 1 "image:" kubernetes/deployment.yaml
```

Environment Variables:

* IMAGE_TAG: Uses the current commit SHA to create a unique image tag.

* GITHUB_REPOSITORY: Format: owner/repo.

* REGISTRY: Assumes the image is stored in GitHub Container Registry (ghcr.io).

What it does:

* Constructs the new image string.
* Uses sed to find and replace the image line in kubernetes/deployment.yaml with the new image.
* Prints the updated image line to verify.


```
- name: Commit and push changes
  run: |
    git add kubernetes/deployment.yaml
    git commit -m "Update Kubernetes deployment with new image tag: ${{ needs.docker.outputs.image_tag }} [skip ci]" || echo "No changes to commit"
    git push
```

* Stages and commits the updated file.
* Commit message includes the image tag from the docker job’s output.
* The || echo "No changes to commit" avoids breaking the job if the file wasn’t modified.
* Pushes the change back to the main branch.








