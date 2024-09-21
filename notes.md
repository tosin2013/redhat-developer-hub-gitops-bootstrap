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

[**Fork this repo**](https://github.com/tosin2013/redhat-developer-hub-gitops-bootstrap/fork) into your own GitHub profile and **Clone it** locally.
![20240917163709](https://i.imgur.com/zABkvTE.png)
## Setup a GitHub Org and an Application

 1. Create a new [**Github Organization**](https://github.com/account/organizations/new?plan=free). This organization will contain the code repositories for the `components` created by Red Hat Developer Hub.

 2. Populate and run the script below 
 ```
oc login --token=sha256~XXXXX --server=https://api.test-cluster.example.com:6443
 ./quicksetup.sh
 ./setup_env.sh
 ```
3.  `./bootstrap-scripts/setup-github-oauth.sh`
4.   `./setup_env.sh`
5. Open the [root-app/app-of-apps.yaml](root-app/app-of-apps.yaml) file and replace any occurency of `redhat-na-ssa` value by your own github profile name (wherever you forked this repo into). 

6. Change the Vault Config resource kustomization file
Because we are using GitOps to configure the Vault Config Operator resources (CRs), we need to replace some values and then commit/push these changes to your forked git repo before we can proceed.

Open the [operators/hashicorp-vault/kustomize/overlays/vault-config/kustomization.yaml](operators/hashicorp-vault/kustomize/overlays/vault-config/kustomization.yaml) file and replace any parameter value you see a replace by... comment.

6. Update the following file [ansible-automation/playbooks/rhdh-install/main.yaml](ansible-automation/playbooks/rhdh-install/main.yaml)
* save, commit and push this change!!!
* authenticate as a cluster-admin on your cluster and execute

## Confgure Environment Variables
```
source .venv/bin/activate
source .ignored/env.sh
export OC_TOKEN=sha256~aLejMLQn4MveklMRThvzsSMNocImcxOHZFYgeIeFddA
export cluster_api_url=https://api.test-cluster.example.com:6443
export ENV_SCRIPT_PATH=/home/example-user/redhat-developer-hub-gitops-bootstrap/.ignored/env.sh
export GITHUB_APP_PRIVATE_KEY_FILE=/home/example-user/redhat-developer-hub-gitops-development/.ignored/github-app.private-key.pem
```

## Bootstrap the Environment
```
 ./bootstrap-scripts/cluster-boostrap.sh 
```

After running both scripts, you can run the playbook using the following command:

```bash
ansible-playbook ansible-automation/playbooks/vault-setup/main.yaml
```

To install and configure Red Hat Developer Hub, run
```bash
ansible-playbook ansible-automation/playbooks/rhdh-install/main.yaml
```

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
