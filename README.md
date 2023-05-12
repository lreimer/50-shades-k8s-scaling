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

```

## Cluster Autoscaling with Karpenter

see https://karpenter.sh/v0.27.3/getting-started/getting-started-with-karpenter/

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.

