import * as pulumi from "@pulumi/pulumi";
import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";

export const name = "pulumi-flux2-cluster";

const latestVersion = gcp.container.getEngineVersions().then(v => v.releaseChannelDefaultVersion['STABLE']);
const cluster = new gcp.container.Cluster(name, {
    minMasterVersion: latestVersion,    
    nodeVersion: latestVersion,
    releaseChannel: { 
        channel: 'STABLE', 
    },
    name: name,
    initialNodeCount: 3,
    nodeConfig: {
        machineType: 'e2-medium'
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

export const clusterProvider = new k8s.Provider(name, {
    kubeconfig: kubeconfig,
});
