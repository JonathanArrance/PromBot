#!/bin/zsh

#Simple script to deploy the demo.

minikube start

wait $!
sleep 2
minikube addons enable ingress

wait $!
sleep 2
minikube addons enable metrics-server

#wait $!
#sleep 2
#helm repo add robusta https://robusta-charts.storage.googleapis.com

wait $!
sleep 5
#Keep the values file out of your root since it has sec keys in it. Do not load into github.
helm install robusta robusta/robusta -f ../generated_values.yaml --set clusterName=PromBot

wait $!
sleep 5

echo "Get the pods see if everyting is up."
kubectl get pods -A

wait $!
sleep 5

echo "Get the Robusta services, make sure they are up"
kubectl get svc | grep robusta

wait $1

echo "Enable the internal Grafana dashboards"
kubectl -n default port-forward svc/robusta-grafana 3000:80&
