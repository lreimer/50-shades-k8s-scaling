# Fifty Shades of Kubernetes Autoscaling

Demo repository for my talk on Fifty Shades of Kubernetes Autoscaling.

## Horizontal Pod Autoscaler

```bash
kubectl apply -f examples/php-apache.yaml

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl apply -f examples/hpa.yaml

kubectl get hpa php-apache --watch
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

## Vertical Pod Autoscaler

```bash
kubectl apply -f examples/hamster.yaml
kubectl apply -f examples/vpa.yaml
kubectl describe vpa hamster-vpa

helm repo add fairwinds-stable https://charts.fairwinds.com/stable
kubectl create namespace goldilocks
helm install goldilocks --namespace goldilocks fairwinds-stable/goldilocks

kubectl edit service goldilocks-dashboard -n goldilocks
kubectl label ns default goldilocks.fairwinds.com/enabled=true
```

## Prometheus Adapter Metrics API

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring
helm install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring
```

## Event-Driven Autoscaling with Keda

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq --set auth.username=user --set auth.password=PASSWORD bitnami/rabbitmq --wait

kubectl apply -f deploy-consumer.yaml
```

## Cluster Autoscaling with Karpenter

Karpenter automatically provisions new nodes in response to unschedulable pods. Karpenter does this by observing events within the Kubernetes cluster, and then sending commands to the underlying cloud provider. Currently, only EKS on AWS is supported. See https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/

To easily install EKS with Karpenter, the `eksctl` tool can be used because it brings Karpenter support. See https://eksctl.io/usage/eksctl-karpenter/

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.

