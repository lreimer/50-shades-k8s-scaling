
create-cluster:
	@pulumi up --yes

cluster-info:
	@pulumi stack output kubeconfig --show-secrets > kubeconfig
	@KUBECONFIG=$(PWD)/kubeconfig kubectl cluster-info
	@KUBECONFIG=$(PWD)/kubeconfig kubectl version
	@KUBECONFIG=$(PWD)/kubeconfig kubectl get nodes

create-cluster:
	@pulumi destroy --yes
