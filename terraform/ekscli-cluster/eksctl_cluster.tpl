apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${cluster_name}
  region: ${cluster_region}
  version: "${cluster_version}"
  tags: ${cluster_tags}

iam:
  withOIDC: false

vpc:
  id: "${cluster_vpc_id}"
  
  clusterEndpoints:
    privateAccess: ${cluster_endpoints_private_access}
    publicAccess: ${cluster_endpoints_public_access}
    
  subnets:
    private: ${private_subnets}
    public: ${public_subnets}

fargateProfiles:
  - name: default-fargate-profile
    selectors:
      - namespace: default
        labels:
          scheduler: fargate
      - namespace: flux-system
      - namespace: kube-system
