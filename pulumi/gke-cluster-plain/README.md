# Plain GKE Cluster using TypeScript Pulumi

## Setup

```bash
export GCP_PROJECT=cloud-native-experience-lab
export GCP_ZONE=europe-west1-b

# create an empty directory
mkdir gke-cluster-plain && cd gke-cluster-plain

# prepare GCP setup
gcloud auth login
gcloud config set project $GCP_PROJECT
gcloud config set compute/zone $GCP_ZONE
gcloud auth application-default login

# create new Pulumi program
pulumi new
pulumi config set gcp:zone $GCP_ZONE
npm install --save @pulumi/kubernetes

code .
```

## Infrastructure as Code

```typescript
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as gcp from "@pulumi/gcp";

const name = "pulumi-autopilot-cluster";

const latestVersion = gcp.container.getEngineVersions().then(v => v.releaseChannelDefaultVersion['STABLE']);
const cluster = new gcp.container.Cluster(name, {
    // minMasterVersion: "1.22.12-gke.2300",
    minMasterVersion: latestVersion,    
    location: "europe-west1",
    // avoid a bug with GKE autopilot cluster defaults
    // https://github.com/pulumi/pulumi-gcp/issues/714
    ipAllocationPolicy: {},
    enableAutopilot: true,
    initialNodeCount: 1,
    releaseChannel: { 
        channel: 'STABLE', 
    },
});

export const clusterName = cluster.name;
export const clusterEndpoint = cluster.endpoint;

// Manufacture a GKE-style kubeconfig. Note that this is slightly "different"
// because of the way GKE requires gcloud to be in the picture for cluster
// authentication (rather than using the client cert/key directly).
export const kubeconfig = pulumi.
    all([cluster.name, cluster.endpoint, cluster.masterAuth]).
    apply(([name, endpoint, masterAuth]) => {
        const context = `gke_${gcp.config.project}_${gcp.config.zone}_${name}`;
        return `apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${masterAuth.clusterCaCertificate}
    server: https://${endpoint}
  name: ${context}
contexts:
- context:
    cluster: ${context}
    user: ${context}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${context}
  user:
    auth-provider:
      config:
        cmd-args: config config-helper --format=json
        cmd-path: gcloud
        expiry-key: '{.credential.token_expiry}'
        token-key: '{.credential.access_token}'
      name: gcp
`;
    });

const clusterProvider = new k8s.Provider(name, {
    kubeconfig: kubeconfig,
});
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
