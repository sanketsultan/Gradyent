# Makefile for Gradyent EKS Solution

.PHONY: all infra app destroy clean

all: infra app

infra:
	cd infra && terraform init && terraform apply -auto-approve

app:
	helm upgrade --install gradyent-task charts/gradyent-task/ --namespace gradyent-task --create-namespace

port-forward:
	kubectl port-forward svc/gradyent-task 8080:8080 -n gradyent-task

hpa:
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

ingress:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

destroy:
	cd infra && terraform destroy -auto-approve

clean:
	cd infra && terraform state rm kubernetes_namespace.velero
	kubectl delete configmap aws-auth -n kube-system
