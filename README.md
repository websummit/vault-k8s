# This is a fork of hashicorp/vault-k8s project used by Web Summit in our K8s clusters

### Motivation
Vault agent is injected by vault-agent-injector (which runs vault-k8s) as an init and/or sidecar
container on every pod through a Kubernetes admission webhook.
These vault agents, as per the original project, allow to use consul-template to populate secrets
and dynamic credentials from Vault into the application pods running on the main container of our
pods. However it doesn't support using consul-template to do the same with consul and populate
configurations, which we use for anything that is not sensitive.

## Changes to the original vault-k8s project
This fork makes 2 specific changes to the original vault-k8s project to address the lack of Consul support:

  * Expose the node's IP to the injected container running vault-agent using the Kubernetes Downward API as
  an environment variable named `HOST_IP`.

  * Configure CONSUL_HTTP_ADDRESS to be used by consul-template by exporting the environment variable directly
  on the arg that runs on the vault-agent container. Specifically CONSUL_HTTP_ADDRESS is set to `<HOST_IP>:8500`
  which in turn allows consul template to communicate with the usual Consul agents running on each node if they
  were enabled on your Consul prefered installation method. We use helm charts for this.

  * We also reduced the default cpu and memory requests and limits since the original defaults were wasting a lot
  of our cluster capacity, we never noticed any for additional resources after a year using this new defaults in
  production.

## Usage
A Makefile task was added to build and push our own images to docker.io. You can find them [here](https://hub.docker.com/r/websummit/custom-vault-k8s/tags)

Simply run:
```
make ws-image
```

---

# Vault + Kubernetes (vault-k8s)

> :warning: **Please note**: We take Vault's security and our users' trust very seriously. If 
you believe you have found a security issue in Vault K8s, _please responsibly disclose_ 
by contacting us at [security@hashicorp.com](mailto:security@hashicorp.com).

The `vault-k8s` binary includes first-class integrations between Vault and
Kubernetes.  Currently the only integration in this repository is the 
Vault Agent Sidecar Injector (`agent-inject`).  In the future more integrations 
will be found here.

The Kubernetes integrations with Vault are
[documented directly on the Vault website](https://www.vaultproject.io/docs/platform/k8s/index.html).
This README will present a basic overview of each use case, but for full
documentation please reference the Vault website.

This project is versioned separately from Vault. Supported Vault versions
for each feature will be noted below. By versioning this project separately,
we can iterate on Kubernetes integrations more quickly and release new versions
without forcing Vault users to do a full Vault upgrade.

## Features

  * [**Agent Inject**](https://www.vaultproject.io/docs/platform/k8s/injector/index.html):
    Agent Inject is a mutation webhook controller that injects Vault Agent containers 
    into pods meeting specific annotation criteria.
    _(Requires Vault 1.3.1+)_

## Installation

`vault-k8s` is distributed in multiple forms:

  * The recommended installation method is the official
    [Vault Helm chart](https://github.com/hashicorp/vault-helm). This will
    automatically configure the Vault and Kubernetes integration to run within
    an existing Kubernetes cluster.

  * A Docker image [`hashicorp/vault-k8s`](https://hub.docker.com/r/hashicorp/vault-k8s) is available. This can be used to manually run `vault-k8s` within a scheduled environment.

  * Raw binaries are available in the [HashiCorp releases directory](https://releases.hashicorp.com/vault-k8s/). These can be used to run vault-k8s directly or build custom packages.
