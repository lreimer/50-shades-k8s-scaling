GCP_PROJECT ?= cloud-native-experience-lab
GCP_ZONE ?= europe-west1-b

prepare-gcp:
	@gcloud auth login
	@gcloud config set project $(GCP_PROJECT)
	@gcloud config set compute/zone $(GCP_ZONE)
	@gcloud auth application-default login

create-cluster:
	@pulumi up --yes

cluster-info:
	@pulumi stack output kubeconfig --show-secrets > kubeconfig
	@KUBECONFIG=$(PWD)/kubeconfig kubectl cluster-info
	@KUBECONFIG=$(PWD)/kubeconfig kubectl version
	@KUBECONFIG=$(PWD)/kubeconfig kubectl get nodes

create-cluster:
	@pulumi destroy --yes
