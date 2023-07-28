# AWS specific variables
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION ?= eu-north-1

# https://cloud.google.com/compute/docs/regions-zones?hl=de#available
GCP_PROJECT ?= cloud-native-experience-lab
GCP_REGION ?= europe-north1
GCP_ZONE ?= europe-north1-b

GITHUB_USER ?= lreimer

prepare-gke-cluster:
	@gcloud config set compute/zone europe-west1-b
	@gcloud config set container/use_client_certificate False

create-gke-cluster:
	@gcloud container clusters create gke-k8s-scaling \
		--release-channel=regular \
		--cluster-version=1.26 \
		--region=$(GCP_REGION) \
		--addons HttpLoadBalancing,HorizontalPodAutoscaling \
		--workload-pool=$(GCP_PROJECT).svc.id.goog \
		--num-nodes=1 \
		--min-nodes=1 --max-nodes=5 \
		--enable-autoscaling \
		--autoscaling-profile=optimize-utilization \
		--enable-vertical-pod-autoscaling \
		--machine-type=e2-medium \
		--logging=SYSTEM \
    	--monitoring=SYSTEM
	@kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@kubectl cluster-info

bootstrap-gke-flux2:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=50-shades-k8s-scaling \
		--branch=main \
		--path=./clusters/gke-k8s-scaling \
		--read-write-key \
		--personal

create-eks-cluster:
	@eksctl create cluster -f eks-k8s-scaling.yaml

bootstrap-eks-flux2:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=50-shades-k8s-scaling \
		--branch=main \
		--path=./clusters/eks-k8s-scaling \
		--read-write-key \
		--personal

delete-clusters: delete-eks-cluster delete-gke-cluster

delete-eks-cluster:
	@eksctl delete cluster -f eks-k8s-scaling.yaml

delete-gke-cluster:
	@gcloud container clusters delete gke-k8s-scaling --async --quiet --region=$(GCP_REGION)
