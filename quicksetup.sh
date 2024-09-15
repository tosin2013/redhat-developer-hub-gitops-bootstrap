#!/bin/bash

# Check if oc is logged in
if ! oc whoami &> /dev/null; then
  echo "You are not logged into an OpenShift cluster. Please log in using 'oc login'."
  exit 1
fi

# Set up environment variables
K8S_CLUSTER_API=$(oc get Infrastructure.config.openshift.io cluster -o=jsonpath="{.status.apiServerURL}")
OPENSHIFT_CLUSTER_INFO=$(echo $K8S_CLUSTER_API | sed 's/^.*https...api//' | sed 's/.6443.*$//')
GITHUB_HOST_DOMAIN=github.com # if using a hosted Enterprise GitHub replace github.com by your internal domain.
GITHUB_ORGANIZATION=tosinsdeveloperhub
GITHUB_ORG_URL=https://$GITHUB_HOST_DOMAIN/$GITHUB_ORGANIZATION
echo "GITHUB_ORG_URL=$GITHUB_ORG_URL"

# Create a new GitHub Application URL
GITHUB_APP_URL="https://$GITHUB_HOST_DOMAIN/organizations/$GITHUB_ORGANIZATION/settings/apps/new?name=$GITHUB_ORGANIZATION-rhdh-app&url=https://janus-idp.io/blog&webhook_active=true&public=false&callback_url=https://developer-hub-rhdh.apps$OPENSHIFT_CLUSTER_INFO/api/auth/github/handler/frame&webhook_url=https://developer-hub-rhdh.apps$OPENSHIFT_CLUSTER_INFO&administration=write&checks=write&actions=write&contents=write&statuses=write&vulnerability_alerts=write&dependabot_secrets=write&deployments=write&discussions=write&environments=write&issues=write&packages=write&pages=write&pull_requests=write&repository_hooks=write&repository_projects=write&secret_scanning_alerts=write&secrets=write&security_events=write&workflows=write&webhooks=write&members=read"

# Echo the GitHub Application URL
echo "Please visit the following URL to create a new GitHub Application:"
echo $GITHUB_APP_URL
echo "Click (or copy and paste it on your web browser) on the link echoed to your terminal and follow the wizard."

# Instructions for manual steps
echo "IMPORTANT❗: Double check your Application has the following permissions set:"
echo "Read access to members and metadata"
echo "Read and write access to Dependabot alerts, actions, administration, checks, code, commit statuses, dependabot secrets, deployments, discussions, environments, issues, packages, pages, pull requests, repository hooks, repository projects, secret scanning alerts, secrets, security events, and workflows"

echo "Generate a new client secret. Copy the App ID, App Client ID, and Client Secret values and paste in a temporary txt file. Then, generate a Private Key for this app and download the private key file."

echo "Go to the 'Install App' on the left side menu and install the GitHub App that you created for your organization. Choose to install it to All Repositories under this Organization."
