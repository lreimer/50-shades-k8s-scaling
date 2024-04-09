# GKE Cluster with Flux2 using TypeScript Pulumi

## Setup

```bash
export GCP_PROJECT=cloud-native-experience-lab
export GCP_ZONE=europe-west1-b

# create an empty directory
mkdir gke-cluster-flux2 && cd gke-cluster-flux2

# prepare GCP setup
gcloud auth login
gcloud config set project $GCP_PROJECT
gcloud config set compute/zone $GCP_ZONE
gcloud auth application-default login

# create new Pulumi program
pulumi new
pulumi config set gcp:zone $GCP_ZONE
npm install --save @pulumi/kubernetes @worawat/flux @pulumi/github @pulumi/tls

code .
```

## Infrastructure as Code

```typescript

```

## Usage

```bash
# to spin everything up
pulumi up
pulumi up --diff

# get kubeconfig for cluster
pulumi stack output kubeconfig --show-secrets > kubeconfig
KUBECONFIG=$(PWD)/kubeconfig kubectl cluster-info
KUBECONFIG=$(PWD)/kubeconfig kubectl version
KUBECONFIG=$(PWD)/kubeconfig kubectl get nodes

# to tear everything down
pulumi destroy --yes
```
