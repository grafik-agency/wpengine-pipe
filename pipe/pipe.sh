#!/usr/bin/env bash
#
# Deploy to wpengine git remote
#
# Required globals:
#   WPE_REPO_URL
#   GIT_EMAIL
#   GIT_NAME
#   ARTIFACT
#   WPE_INSTALL_ID
#   WPE_API_USER
#   WPE_API_PASSWORD

source "$(dirname "$0")/common.sh"

# mandatory parameters
WPE_REPO_URL=${WPE_REPO_URL:?'WPE_REPO_URL variable missing.'}
WPE_INSTALL_ID=${WPE_INSTALL_ID:?'WPE_INSTALL_ID variable missing.'}
WPE_API_USER=${WPE_API_USER:?'WPE_API_USER variable missing.'}
WPE_API_PASSWORD=${WPE_API_PASSWORD:?'WPE_API_PASSWORD variable missing.'}
GIT_EMAIL=${GIT_EMAIL:?'GIT_EMAIL variable missing.'}
GIT_NAME=${GIT_NAME:?'GIT_NAME variable missing.'}
ARTIFACT=${ARTIFACT:?'ARTIFACT variable missing.'}

info "Running wpengine pipe..."

# copies repo ssh keys into pipe image
configure_ssh() {
    info "configuring ssh keys..."
        mkdir -p ~/.ssh
        cp /opt/atlassian/pipelines/agent/ssh/id_rsa_tmp ~/.ssh/id_rsa
        cp /opt/atlassian/pipelines/agent/ssh/known_hosts ~/.ssh/known_hosts
        chmod -R go-rwx ~/.ssh/
}
configure_ssh

# pushes artifact into target remote 
push_to_wpe() {
    info "Deploying to to ${WPE_REPO_URL}..."
        info "Configuring git..."
        git config --global user.email "${GIT_EMAIL}"
        git config --global user.email "${GIT_NAME}"
        mkdir deploy
        mv ${ARTIFACT} deploy
        cd deploy
        success "Artifact has been moved to deploy"
        info "Unzipping artifact..."
        unzip -o ${ARTIFACT}
        rm -rf ${ARTIFACT}
        success "Successfuly unzipped artifact!"
        ls
        git init
        git remote add origin ${WPE_REPO_URL}
        git add .
        git branch -M master
        git commit -m "$BITBUCKET_COMMIT"
        git push -uf ${WPE_REPO_URL}
}


# takes a backup of target install
backup_wpe_install() {
    printf -v data -- '{"description": "Before Bitbucket deploy", "notification_emails": ["%s"]}' \
    "${GIT_EMAIL}"
    info "Backing up site before git push..."
    STATUS=$(curl --write-out "%{http_code}\n" -X POST "https://api.wpengineapi.com/v1/installs/${WPE_INSTALL_ID}/backups" \
        -H "Content-Type: application/json" \
        -d "$data" \
        -u ${WPE_API_USER}:${WPE_API_PASSWORD} \
        --output output.txt --silent)
    if [ "$STATUS" == 202 ]
        then
            success "$STATUS: Successfuly created a backup!"
            push_to_wpe
        else
            fail "$STATUS: failed to create a backup!"
    fi
}
backup_wpe_install

success "Successfuly synced files with wpengine!"
