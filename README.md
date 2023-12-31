# Use a robot to help fix Kubernetes issues and apps.

Kubernetes can be complex, why go it alone when you can use the OpenAI LLM to help you solve the issues that come up.

## Components

In order to be successful in this project you will need to make sure you have a few things set up and installed beforhand. The set up for most of these components is outside of the scope of this project.

**NOTE:** MacOS was used to set up a test dev environment, Homebrew was used to set up the environemnt. Install [HomeBrew](https://brew.sh)


**Slack** - If you do not already have a channel set up for your Kubernetes troubleshooting, create one before you start. 

**Docker** - Containerization engine used.

**Minikube** - Use Minikube to quickly deploy a test and dev environment on your laptop. 

**Full Kubernetes Deployemnt** - Full k8s deployment used for production or testing.

**Helm** - Kubernetes package management, Helm is used to deploy all of the components in this deonstration.

**Robusta** - An open source Kubernetes observability tool for Kubernetes that extends Prometheus.

**Robusta OpenAI integration** - The bot sends a query to OpenAI, asking it how to fix your alerts.

**OpenAI API Access** - If you are outside of the 30day trial period, a payed access to the OpenAI API 


## Set up minikube

Minikube is used to set up a small test dev environment. 

[Minikube start](https://minikube.sigs.k8s.io/docs/start/)

```bash
brew install minikube

minikube start

minikube addons enable ingress

minikube dashboard --url
```

## Install Helm

Install Helm with Homebrew, no special config is need for the test environment.

[Helm Commands](https://helm.sh/docs/helm/)

```bash
brew install helm
```

## Set up Robusta

The Robusta install is all Helm based. Robusta can be used in an environment where Prometheus is already in use, or Prometheus can be deployed with Robusta.

**NOTE:** This demo uses Robusta to install Prometheus.

Install the Python based Robusta CLI.

```bash
pip install -U robusta-cli --no-cache
```

We will need to create a the Robusta "Generated Values" file using the cli. This will not install Robusta it is only the config Yaml file.

```bash
robusta gen-config --enable-prometheus-stack
```

Answer the prompts and a file called generated_values.yaml is created.

**NOTE:** At this point the OpenAI plugin is not added to the generated yaml config. 

Set up the Helm chart and deploy Robusta in your Minikube environment.

```bash
helm repo add robusta https://robusta-charts.storage.googleapis.com

helm install robusta robusta/robusta -f ./generated_values.yaml --set clusterName=PromBot
```

Check to see if the Robusta components are running

```bash
kubectl get svc

NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
prometheus-operated                       ClusterIP   None             <none>        9090/TCP                     51m
robusta-grafana                           ClusterIP   10.109.88.8      <none>        80/TCP                       51m
robusta-kube-prometheus-st-alertmanager   ClusterIP   10.110.61.226    <none>        9093/TCP                     51m
robusta-kube-prometheus-st-operator       ClusterIP   10.98.86.189     <none>        443/TCP                      51m
robusta-kube-prometheus-st-prometheus     ClusterIP   10.109.214.172   <none>        9090/TCP                     51m
robusta-kube-state-metrics                ClusterIP   10.108.233.213   <none>        8080/TCP                     51m
robusta-prometheus-node-exporter          ClusterIP   10.109.147.8     <none>        9104/TCP                     51m
robusta-runner                            ClusterIP   10.109.16.144    <none>        80/TCP                       51m
```

Expose Robusta Grafana dashboards

**NOTE:** We are using port 3000, change the port to fit your environment

```bash
kubectl -n default port-forward svc/robusta-grafana 3000:80
```

Local Grafana [dashboards](http://127.0.0.1:3000/dashboards)


## Add the OpenAI Plugin AKA ChatGPT

### Robusta ChatGPT integration

Please view the original code and setup instructions here:

This code has been copied from https://github.com/robusta-dev/kubernetes-chatgpt-bot/tree/main

This code has several mods to the LLM prompts that will help give actual Kubernetes kubectl commands.

### Prerequisites
* A Slack workspace
* Working Kubernetes cluster

### Setup
1. [Install Robusta with Helm](https://docs.robusta.dev/master/installation.html)
2. Load the ChatGPT playbook. Add the following to `generated_values.yaml`: 

```bash
playbookRepos:
  chatgpt_robusta_actions:
    url: "https://github.com/JonathanArrance/PromBot.git"

customPlaybooks:
# Add the 'Ask ChatGPT' button to all Prometheus alerts
- triggers:
  - on_prometheus_alert: {}
  actions:
  - chat_gpt_enricher: {}
```

3. Add your [OpenAI API key](https://beta.openai.com/account/api-keys) to `generated_values.yaml`. Make sure you edit the existing `globalConfig` section, don't add a duplicate section.

```bash
globalConfig:
  chat_gpt_token: YOUR KEY GOES HERE
```

4. Do a Helm upgrade to apply the new values: `helm upgrade robusta robusta/robusta --values=generated_values.yaml --set clusterName=<YOUR_CLUSTER_NAME>`

5. [Send your Prometheus alerts to Robusta](https://docs.robusta.dev/master/user-guide/alert-manager.html). Alternatively, just use Robusta's bundled Prometheus stack.

### Demo
Instead of waiting around for a Prometheus alert, lets cause one.

1. Deploy a broken pod that will be stuck in pending state:

```bash
kubectl apply -f https://gist.githubusercontent.com/robusta-lab/283609047306dc1f05cf59806ade30b6/raw
```

2. Trigger a Prometheus alert immediately, skipping the normal delays:

```bash
robusta playbooks trigger prometheus_alert alert_name=KubePodCrashLooping namespace=default pod_name=example-pod
```

An alert will arrive in Slack with a button. Click the button to ask ChatGPT about the alert.

3. Cleanup the crash pod

```bash
kubectl delete deployment crashpod
```

## Cleanup the dev testbed

When you want to remove Robusta from your cluster.

```bash
helm uninstall robusta robusta/robusta

minikube stop
```

## Sources

[Robusta Docs](https://docs.robusta.dev/master/)

[Robusta Source](https://github.com/robusta-dev/robusta)

[Robusta ChatGPT Bot](https://github.com/robusta-dev/kubernetes-chatgpt-bot/tree/main)

[Helm](https://helm.sh)

[Minikube](https://minikube.sigs.k8s.io/docs/)

[Brew](https://brew.sh)
