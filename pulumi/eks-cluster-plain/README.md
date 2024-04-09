# Plain EKS Cluster with TypeScript Pulumi

## Setup

```bash
# at least v2.7.0 of aws-cli is required
export AWS_ACCESS_KEY_ID=ABC123_CHANGE_ME
export AWS_SECRET_ACCESS_KEY=1234abcd+changeme

# create an empty directory
mkdir eks-cluster-plain && cd eks-cluster-plain

# create new Pulumi program
pulumi new aws-typescript
npm install --save @pulumi/eks @pulumi/kubernetes

code .
```

## Infrastructure as Code

```typescript
import * as eks from "@pulumi/eks";

const name = "pulumi-plain-cluster";
const cluster = new eks.Cluster(name, {
    version: '1.22',
    // use default VPC, do not set vpcId
    useDefaultVpcCni: true,
    minSize: 3,
    maxSize: 5,
    desiredCapacity: 3,
    encryptRootBlockDevice: true,
    createOidcProvider: true,
    name: name,
});

export const clusterUrn = cluster.urn;
export const kubeconfig = cluster.kubeconfig;
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
