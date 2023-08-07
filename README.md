# Use a robot to help fix Kubernetes issues and apps.

Kubernetes can be complex, why go it alone when you can use the OpenAI LLM to help you solve the issues that come up.

## Components

In order to be successful in this project you will need to make sure you have a few things set up and installed beforhand. The set up for most of these components is outside of the scope of this project.

NOTE: MacOS was used to set up a test dev environment, Homebrew was used to set up the environemnt. Install [HomeBrew](https://brew.sh)

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

The Robusta install is all Helm based. Robusta can be used in an environment where Prometheus is alread in use, or Prometheus can be deployed with Robusta.

NOTE: This demo uses Robusta to install Prometheus.

Install the Python based Robusta CLI.
```bash
pip install -U robusta-cli --no-cache
```

We will need to create a the Robusta "Generated Values" file using the cli. This will not install Robusta it is only the config Yaml file.

```bash
robusta gen-config --enable-prometheus-stack
```

Set up the Helm chart and deploy Robusta in your Minikube environment.


```bash
helm repo add robusta https://robusta-charts.storage.googleapis.com && helm repo update

helm install robusta robusta/robusta -f ./generated_values.yaml --set clusterName=PromBot
```

## Sources

[Robusta Docs](https://docs.robusta.dev/master/)

[Robusta ChatGPT Bot](https://github.com/robusta-dev/kubernetes-chatgpt-bot/tree/main)

[Helm](https://helm.sh)

[Minikube](https://minikube.sigs.k8s.io/docs/)

[Brew](https://brew.sh)
