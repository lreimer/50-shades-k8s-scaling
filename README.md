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

## Cluster Rightsizing

Depending on the Cloud provider there are different options to autoscale and thus rightsize the cluster itself, so that the number of nodes is sufficient to handle the current load but not more.

```bash
# add a deployment to demo cluster autoscaling
kubectl apply -f karpenter/inflate.yaml

# to trigger and watch a cluster ScaleUp
kubectl scale deployment inflate --replicas 5
kubectl get pods
kubectl describe pod inflate-644ff677b7-jgw8r
kubectl events
kubectl get nodes -w

# to trigger and watch a cluster ScaleDown
kubectl scale deployment inflate --replicas 0
kubectl get pods
kubectl events
kubectl get nodes -w
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

kubectl label ns default goldilocks.fairwinds.com/enabled=true

helm repo add fairwinds-stable https://charts.fairwinds.com/stable
kubectl create namespace goldilocks
helm install goldilocks --namespace goldilocks fairwinds-stable/goldilocks

kubectl edit service goldilocks-dashboard -n goldilocks
export GOLDILOCKS_IP=`kubectl get service goldilocks-dashboard -n goldilocks -o jsonpath="{.status.loadBalancer.ingress[0].ip}"`

# use Goldilocks dashboard to display recommendations
kubectl get service goldilocks-dashboard -n goldilocks
open http://$GOLDILOCKS_IP:80
```

## Prometheus Custom Metrics and HPA

see https://github.com/kubernetes-sigs/prometheus-adapter

```bash
# for some K8s distributions you need to install the Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring
helm install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring
```

## Time-based Autoscaling using kube-green

Don't waste resources! Many workloads on dev/qa environments stay running during weekends,
non working hours or at night. _kube-green_ is a simple K8s addon to automatically shutdown
and restart resources based on when they are needed (or not).

```yaml
apiVersion: kube-green.com/v1alpha1
kind: SleepInfo
metadata:
  name: non-working-hours
spec:
  weekdays: "1-5"
  sleepAt: "18:00"
  wakeUpAt: "08:00"
  timeZone: "Europe/Rome"
  suspendCronJobs: true
  excludeRef:
    - apiVersion: "apps/v1"
      kind:       Deployment
      name:       no-sleep-deployment
    - matchLabels: 
        kube-green.dev/exclude: "true"
```

To see some details when the above `SleepInfo` resource will be schedules next, you can have a look at the log output from the _kube-green-controller-manager_ pod.
```bash
kubectl logs pod/kube-green-controller-manager-5855848d7f-dftxd -n kube-green
```

## Event-Driven Autoscaling with Keda

_KEDA is a Kubernetes-based Event Driven Autoscaler that allows granular scaling of workloads in Kubernetes, based on multiple defined parameters, leveraging the concept of built for purpose scalers._

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq --set auth.username=user --set auth.password=PASSWORD bitnami/rabbitmq --wait

# https://keda.sh/docs/2.12/scalers/metrics-api/
# https://keda.sh/docs/2.12/scalers/loki/
# https://keda.sh/docs/2.12/scalers/influxdb/

# do the same as before with kube-green
kubectl apply -f keda/cron-scaledobject.yaml

kubectl apply -f keda/deploy-consumer.yaml
kubectl get deployments
kubectl get pods -w
kubectl apply -f keda/deploy-publisher-job.yaml
```

## Carbon Aware Scaling and Temporal Shifting with KEDA

_To build a Kubernetes application with carbon aware scaling, we need to implement demand shaping that scales workloads based on the current carbon intensity of the location where the Kubernetes cluster is deployed. To achieve this using KEDA, you can set up the newly introduced KEDA carbon-aware scaler for your Kubernetes workloads and define your carbon intensity scaling thresholds._  

(https://www.tfir.io/carbon-aware-kubernetes-scaling-a-step-towards-greener-cloud-computing/)

```bash
# detailled installation instructions can be found in the Github repos
open https://github.com/Azure/carbon-aware-keda-operator
open https://github.com/Azure/kubernetes-carbon-intensity-exporter

# you will also need the sources
# install the intensity exporter
git clone https://github.com/Azure/kubernetes-carbon-intensity-exporter.git
cd kubernetes-carbon-intensity-exporter

export WATTTIME_USERNAME=lreimer
export WATTTIME_PASSWORD=
export LOCATION=se
# export LOCATION=westus

helm install carbon-intensity-exporter \
        --set carbonDataExporter.region=$LOCATION \
        --set wattTime.username=$WATTTIME_USERNAME \
        --set wattTime.password=$WATTTIME_PASSWORD \
        ./charts/carbon-intensity-exporter

# check the carbon data
kubectl get pod -n kube-system | grep carbon-intensity-exporter
kubectl get cm -n kube-system carbon-intensity -o jsonpath='{.data}' | jq
kubectl get cm -n kube-system carbon-intensity -o jsonpath='{.binaryData.data}' | base64 --decode | jq

# install the carbon aware operator
git clone https://github.com/Azure/carbon-aware-keda-operator.git
cd carbon-aware-keda-operator
version=$(git describe --abbrev=0 --tags)
kubectl apply -f "https://github.com/Azure/carbon-aware-keda-operator/releases/download/${version}/carbonawarekedascaler-${version}.yaml"

# deply the carbon aware scaler
kubectl apply -f keda/deploy-consumer.yaml
kubectl apply -f keda/deploy-publisher-job.yaml
kubectl apply -f keda/carbon-aware-scaler.yaml
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

