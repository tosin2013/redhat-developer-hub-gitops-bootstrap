# Red Hat Developer Hub Gitops Cluster Bootstrap

This project repo contains a set of ArgoCD manifests and a set of Ansible Playbooks used to bootstrap a Developer Hub Environment on top of Openshift v4.x. The produced environment is intended for Developer workflows demo.

It uses the ArgoCD **App of Apps pattern** to pre-install and configure a set of Openshift Operators to support Developer Workflows.

The following components should be provisioned by ArgoCD in your cluster:
 * **Openshift Dev Spaces**
 * **Kubernetes Image Puller Operator**
 * **Git Webhook Operator**
 * **Hashicorp Vault**
 * **Vault Config Operator**
 * **Openshift Pipelines**
 * **Patch Operator**
 * **...** (this list keeps growing as I need to add new components to this demo)

# First things first

[**Fork this repo**](https://github.com/redhat-na-ssa/redhat-developer-hub-gitops-bootstrap/fork) into your own GitHub profile and **Clone it** locally.

## Setup a GitHub Org and an Application

 1. Create a new [**Github Organization**](https://github.com/account/organizations/new?plan=free). This organization will contain the code repositories for the `components` created by Red Hat Developer Hub.

 2. Populate and run the script below 
 ```
 vim ./quickstart.sh
 ./quickstart.sh
 ```
3. bootstrap-scripts/enable-htpasswd-users.sh
4. Open the [root-app/app-of-apps.yaml](root-app/app-of-apps.yaml) file and replace any occurency of `redhat-na-ssa` value by your own github profile name (wherever you forked this repo into). 

* save, commit and push this change!!!
* authenticate as a cluster-admin on your cluster and execute

## Uninstall the Environment

To uninstall the environment, you can run the following Ansible playbooks to delete the Kubernetes resources created by the setup playbooks:

1. **Uninstall RHDH**:
   ```bash
   ansible-playbook ansible-automation/playbooks/rhdh-install/uninstall_rhdh.yml
   ```

2. **Uninstall Vault**:
   ```bash
   ansible-playbook ansible-automation/playbooks/vault-setup/uninstall_vault.yml
   ```

These commands will remove the resources created by the setup playbooks, effectively uninstalling the environment.
