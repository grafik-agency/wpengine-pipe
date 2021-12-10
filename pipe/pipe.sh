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

configure_ssh() {
    info "configuring ssh keys..."
        mkdir -p ~/.ssh
        cp /opt/atlassian/pipelines/agent/ssh/id_rsa_tmp ~/.ssh/id_rsa
        cp /opt/atlassian/pipelines/agent/ssh/known_hosts ~/.ssh/known_hosts
        chmod -R go-rwx ~/.ssh/
}
configure_ssh

backup_wpe_install() {
    printf -v data -- '{"description": "Before Bitbucket deploy", "notification_emails": ["%s"]}' \
    "${GIT_EMAIL}"
    info "Backing up site before git push..."
        curl -X POST "https://api.wpengineapi.com/v1/installs/${WPE_INSTALL_ID}/backups" \
            -H "Content-Type: application/json" \
            -d "$data" \
            -u ${WPE_API_USER}:${WPE_API_PASSWORD}
    success "Request to backup successful!"
}
backup_wpe_install

push_to_wpe() {
    info "Deploying to to ${WPE_REPO_URL}..."
        info "Configuring git..."
        rm -rf .git
        git config --global user.email "${GIT_EMAIL}"
        git config --global user.email "${GIT_NAME}"
        info "Cloning remote repository..."
        git clone ${WPE_REPO_URL} deploy
        mv ${ARTIFACT} .gitignore README.md deploy
        cd deploy
        ls | grep -v ${ARTIFACT} | grep -v .gitignore | grep -v README.md | xargs rm -rf
        unzip ${ARTIFACT}
        git status
        git commit -m "$BITBUCKET_COMMIT" -a
        git push origin master
        git push -f ${WPE_REPO_URL}
}
push_to_wpe

success "Successfuly synced files with wpengine!"