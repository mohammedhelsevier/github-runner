$CONTAINER_IMAGE_NAME="github-actions-runner:1.0"
$CONTAINER_REGISTRY_NAME="tioceeghrunneracr"
$LOCATION="EAST US 2"
$CLIENT_ID="Iv23liNBiUjabnZ89Oii"
$PEM_PATH=""
$RESOURCE_GROUP="6bdd229b3420-eastus2-application-rg"
$secret="3f3e08946f0fc2c6cf026e855ab989cc65a18529"
$GITHUB_PAT="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"
$REPO_OWNER="elsevierPTG"
$REPO_NAME="Azure-infrastructurearchitecture"
$ENVIRONMENT="tio-cee-bootstrap-ghrunner-env"
$JOB_NAME="tio-cee-bootstrap-ghrunner-job"
az acr create --name "$CONTAINER_REGISTRY_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku Basic --admin-enabled true

az acr build --registry "$CONTAINER_REGISTRY_NAME" --image "$CONTAINER_IMAGE_NAME" --file "Dockerfile.github" "https://github.com/Azure-Samples/container-apps-ci-cd-runner-tutorial.git"

az containerapp job create -n "$JOB_NAME" -g "$RESOURCE_GROUP" `
--environment "$ENVIRONMENT" --trigger-type Event --replica-timeout 1800 `
--replica-retry-limit 0 --replica-completion-count 1 --parallelism 1 `
--image "$CONTAINER_REGISTRY_NAME.azurecr.io/$CONTAINER_IMAGE_NAME" `
--min-executions 0 --max-executions 10 --polling-interval 30 --scale-rule-name "github-runner" `
--scale-rule-type "github-runner" --scale-rule-metadata "githubAPIURL=https://api.github.com" "owner=$REPO_OWNER" "runnerScope=repo" "repos=$REPO_NAME" "targetWorkflowQueueLength=1" `
--scale-rule-auth "personalAccessToken=personal-access-token" `
--cpu "2.0" --memory "4Gi" --secrets "personal-access-token=$GITHUB_PAT" `
--env-vars "GITHUB_PAT=secretref:personal-access-token" "GH_URL=https://github.com/$REPO_OWNER/$REPO_NAME" "REGISTRATION_TOKEN_API_URL=https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runners/registration-token" `
--registry-server "$CONTAINER_REGISTRY_NAME.azurecr.io"
