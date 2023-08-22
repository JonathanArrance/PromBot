#!/bin/zsh

kubectl -n default delete svc/robusta-grafana

helm uninstall robusta robusta/robusta

wait $!

minikube stop

echo "Dev testbed shut down"
