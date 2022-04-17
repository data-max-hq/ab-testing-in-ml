all: minikube

hello:
	echo "hello world"

minikube:
		minikube start --memory 10000 --cpus 4 \
		--insecure-registry "10.0.0.0/24" \
		--driver=docker --kubernetes-version=v1.21.6 \
		--mountls
