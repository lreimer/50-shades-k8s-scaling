// import * as pulumi from "@pulumi/pulumi";
// import * as aws from "@pulumi/aws";
// import * as awsx from "@pulumi/awsx";
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
