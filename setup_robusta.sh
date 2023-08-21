#!/bin/zsh

minikube start

wait $!
minikube addons enable ingress

wait $!
minikube addon enable metrics-server

wait $!
minikube addon enable metrics-server

wait $!
helm repo add robusta https://robusta-charts.storage.googleapis.com

wait $!
#Keep the values file out of your root since it has sec keys in it. Do not load into github.
helm install robusta robusta/robusta -f ../generated_values.yaml --set clusterName=PromBot

wait $!
echo "Get the pods see if everyting is up."
kubectl get pods -A

wait $!

echo "Get the Robusta services, make sure they are up/"
kubectl get svc | grep robusta

wait $1

echo "Enable 
kubectl -n default port-forward svc/robusta-grafana 3000:80&