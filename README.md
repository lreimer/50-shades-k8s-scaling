# Fifty Shades of Kubernetes Autoscaling

Demo repository for my talk on Fifty Shades of Kubernetes Autoscaling.

## Setup

```bash
export GITHUB_USER=lreimer
export GITHUB_TOKEN=

# for the GKE cluster setup
make create-gke-cluster
make bootstrap-gke-flux2

kubectl edit service kube-prometheus-stack-grafana -n monitoring
export GRAFANA_IP=`kubectl get service kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.status.loadBalancer.ingress[0].ip}"`

kubectl edit service goldilocks-dashboard -n goldilocks
export GOLDILOCKS_IP=`kubectl get service goldilocks-dashboard -n goldilocks -o jsonpath="{.status.loadBalancer.ingress[0].ip}"`

# for the EKS cluster setup
make create-eks-cluster
make bootstrap-eks-flux2

kubectl edit service kube-prometheus-stack-grafana -n monitoring
export GRAFANA_HOSTNAME=`kubectl get service kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"`
```




## Prometheus Adapter Metrics API

```bash
# for some K8s distributions you need to install the Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring
helm install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring
```

## Horizontal Pod Autoscaler

```bash
kubectl apply -f horizontal/php-apache.yaml

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl apply -f horizontal/hpa.yaml

kubectl get hpa php-apache --watch
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

## Vertical Pod Autoscaler

```bash
kubectl apply -f vertical/hamster.yaml
kubectl apply -f vertical/vpa.yaml
kubectl describe vpa hamster-vpa

helm repo add fairwinds-stable https://charts.fairwinds.com/stable
kubectl create namespace goldilocks
helm install goldilocks --namespace goldilocks fairwinds-stable/goldilocks

kubectl edit service goldilocks-dashboard -n goldilocks
export GOLDILOCKS_IP=`kubectl get service goldilocks-dashboard -n goldilocks -o jsonpath="{.status.loadBalancer.ingress[0].ip}"`

kubectl label ns default goldilocks.fairwinds.com/enabled=true
```

## Event-Driven Autoscaling with Keda

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq --set auth.username=user --set auth.password=PASSWORD bitnami/rabbitmq --wait

kubectl apply -f keda/deploy-consumer.yaml
kubectl get deployments
kubectl get pods -w
kubectl apply -f keda/deploy-publisher-job.yaml
```

## Google GKE with Cluster Autoscaler

```bash
# create GKE cluster using gcloud CLI
gcloud container clusters create gke-k8s-scaling \
    # enable GKE addons such as HPA support
	--addons HttpLoadBalancing,HorizontalPodAutoscaling \
    
    # enable VPA support
	--enable-vertical-pod-autoscaling \

    # enable cluster autoscaling
    # use profile for moderate (Balanced) or aggessive (Optimize-utilization) mode
	--enable-autoscaling \
	--autoscaling-profile=optimize-utilization \
    
    # specify initial node pool size and scaling limits
	--num-nodes=1 \
	--min-nodes=1 --max-nodes=5
```

## Cluster Autoscaling with Karpenter

Karpenter automatically provisions new nodes in response to unschedulable pods. Karpenter does this by observing events within the Kubernetes cluster, and then sending commands to the underlying cloud provider. Currently, only EKS on AWS is supported. See https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/

To easily install EKS with Karpenter, the `eksctl` tool can be used because it brings Karpenter support. See https://eksctl.io/usage/eksctl-karpenter/

```bash
# configure Karpenter behaviour
kubectl apply -f karpenter/karpenter.yaml

# add a deployment to demo cluster autoscaling
kubectl apply -f karpenter/inflate.yaml

# to trigger and watch a cluster ScaleUp
kubectl scale deployment inflate --replicas 5
kubectl get pods
kubectl describe pod inflate-644ff677b7-jgw8r
kubectl get events
kubectl get nodes -w

# to trigger and watch a cluster ScaleDown
kubectl scale deployment inflate --replicas 0
kubectl get pods
kubectl get events
kubectl get nodes -w
```

## Descheduler for Kubernetes

For more details and usage instructions, see https://github.com/kubernetes-sigs/descheduler

```bash
# deploy Descheduler either as Job, CronJob or Deployment
# either via Helm, Kustomize or plain YAML
kubectl apply -k descheduler/v0.26.1/
```

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.

