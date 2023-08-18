#!/bin/zsh

#lets deploy a broken pod and then fire off the playbook - we shoudl see the message in Slack

kubectl apply -f https://gist.githubusercontent.com/robusta-lab/283609047306dc1f05cf59806ade30b6/raw

sleep 3

robusta playbooks trigger prometheus_alert alert_name=KubePodCrashLooping namespace=default pod_name=example-pod