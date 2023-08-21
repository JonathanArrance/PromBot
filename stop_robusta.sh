#!/bin/zsh

helm uninstall robusta robusta/robusta

wait $!

minikube stop

echo "Dev testbed shut down"