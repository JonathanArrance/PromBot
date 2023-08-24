#!/bin/zsh

kubectl -n default delete svc/robusta-grafana

sleep 1

helm uninstall robusta robusta/robusta

wait $!
sleep 5
minikube stop

echo "Dev testbed shut down"
