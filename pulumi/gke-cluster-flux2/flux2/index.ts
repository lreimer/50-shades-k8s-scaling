import * as pulumi from "@pulumi/pulumi";
import * as tls from "@pulumi/tls";
import * as github from "@pulumi/github";
import * as k8s from "@pulumi/kubernetes";
import * as flux from "@worawat/flux";

const githubOwner = "qaware";
const repoName = "cloud-native-explab";
const branch = "main";
const targetPath = "clusters/gcp/pulumi-flux2-cluster";
const knownHosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";

export const key = new tls.PrivateKey("key", {
    algorithm: "ECDSA",
    ecdsaCurve: "P256",
});

const repo = await github.getRepository({
    fullName: `${githubOwner}/${repoName}`
});

new github.RepositoryDeployKey("key", {
    title: "pulumi-flux2-cluster",
    repository: repo.fullName,
    key: key.publicKeyOpenssh,
    readOnly: false,
  });

  const fluxInstall = await flux.getFluxInstall({
    targetPath: targetPath,
  });
  
  const fluxSync = await flux.getFluxSync({
    targetPath: targetPath,
    url: `ssh://git@github.com/${githubOwner}/${repoName}.git`,
    branch: branch,
  });
  
  // Create kubernetes resource from generated manifests
  const install = new k8s.yaml.ConfigGroup("flux-install", {
    yaml: fluxInstall.content,
  });
  
  const sync = new k8s.yaml.ConfigGroup("flux-sync", {
    yaml: fluxSync.content,
  });
  
  new k8s.core.v1.Secret(
    "flux",
    {
      metadata: {
        name: fluxSync.secret,
        namespace: fluxSync.namespace,
      },
      stringData: {
        identity: key.privateKeyPem,
        "identity.pub": key.publicKeyPem,
        known_hosts: knownHosts,
      },
    },
    { dependsOn: install }
  );
  
  // Commit files to Github
  new github.RepositoryFile(
    "install",
    {
      repository: repo.name,
      file: fluxInstall.path,
      content: fluxInstall.content,
      branch: branch,
    },
    { dependsOn: install }
  );
  
  new github.RepositoryFile(
    "sync",
    {
      repository: repo.name,
      file: fluxSync.path,
      content: fluxSync.content,
      branch: branch,
    },
    { dependsOn: install }
  );
  
  new github.RepositoryFile(
    "kustomize",
    {
      repository: repo.name,
      file: fluxSync.kustomizePath,
      content: fluxSync.kustomizeContent,
      branch: branch,
    },
    { dependsOn: install }
  );
  