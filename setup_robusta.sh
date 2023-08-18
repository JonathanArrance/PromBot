#!/bin/zsh

helm repo add robusta https://robusta-charts.storage.googleapis.com

helm install robusta robusta/robusta -f ../generated_values.yaml --set clusterName=PromBot