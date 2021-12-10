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

# mandatory parameters
WPE_REPO_URL=${WPE_REPO_URL:?'WPE_REPO_URL variable missing.'}
WPE_INSTALL_ID=${WPE_INSTALL_ID:?'WPE_INSTALL_ID variable missing.'}
WPE_API_USER=${WPE_API_USER:?'WPE_API_USER variable missing.'}
WPE_API_PASSWORD=${WPE_API_PASSWORD:?'WPE_API_PASSWORD variable missing.'}
GIT_EMAIL=${GIT_EMAIL:?'GIT_EMAIL variable missing.'}
GIT_NAME=${GIT_NAME:?'GIT_NAME variable missing.'}
ARTIFACT=${ARTIFACT:?'ARTIFACT variable missing.'}

backup_wpe_install() {
    info "Backing up site before git push..."
        curl -X POST "https://api.wpengineapi.com/v1/installs/${WPE_INSTALL_ID}/backups" -u ${WPE_API_USER}:${WPE_API_PASSWORD}
}
backup_wpe_install

push_to_wpe() {
    info "Deploying to to ${WPE_REPO_URL}..."
        rm -rf .git
        git config --global user.email "${GIT_EMAIL}"
        git config --global user.email "${GIT_NAME}"
        git clone git@git.wpengine.com:production/${WPE_REPO_URL} deploy
        mv ${ARTIFACT} .gitignore README.md deploy
        rm -rf `ls --ignore=${ARTIFACT} --ignore=.gitignore --ignore=README.md`
        unzip ${ARTIFACT}
        git status
        git add . && git commit -m "$BITBUCKET_COMMIT"
        git push origin master
        git push -f ${WPE_REPO_URL}
}
push_to_wpe