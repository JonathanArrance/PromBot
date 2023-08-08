# Robusta ChatGPT integration

Please view the original code and setup instructions here:

This code has been copied from https://github.com/robusta-dev/kubernetes-chatgpt-bot/tree/main

This code has several mods to the LLM prompts that will help give actual Kubernetes kubectl commands.

# Prerequisites
* A Slack workspace

# Setup
1. [Install Robusta with Helm](https://docs.robusta.dev/master/installation.html)
2. Load the ChatGPT playbook. Add the following to `generated_values.yaml`: 
```
playbookRepos:
  chatgpt_robusta_actions:
    url: "https://github.com/robusta-dev/kubernetes-chatgpt-bot.git"

customPlaybooks:
# Add the 'Ask ChatGPT' button to all Prometheus alerts
- triggers:
  - on_prometheus_alert: {}
  actions:
  - chat_gpt_enricher: {}
```

3. Add your [OpenAI API key](https://beta.openai.com/account/api-keys) to `generated_values.yaml`. Make sure you edit the existing `globalConfig` section, don't add a duplicate section.

```
globalConfig:
  chat_gpt_token: YOUR KEY GOES HERE
```

4. Do a Helm upgrade to apply the new values: `helm upgrade robusta robusta/robusta --values=generated_values.yaml --set clusterName=<YOUR_CLUSTER_NAME>`

5. [Send your Prometheus alerts to Robusta](https://docs.robusta.dev/master/user-guide/alert-manager.html). Alternatively, just use Robusta's bundled Prometheus stack.

# Demo
Instead of waiting around for a Prometheus alert, lets cause one.

1. Deploy a broken pod that will be stuck in pending state:

```
kubectl apply -f https://raw.githubusercontent.com/robusta-dev/kubernetes-demos/main/pending_pods/pending_pod.yaml
```

2. Trigger a Prometheus alert immediately, skipping the normal delays:

```
robusta playbooks trigger prometheus_alert alert_name=KubePodCrashLooping namespace=default pod_name=example-pod
```

An alert will arrive in Slack with a button. Click the button to ask ChatGPT about the alert.