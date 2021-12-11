# WP Engine Bitbucket Pipe

A pipe for integrating your wpengine deployments. This method allows for cleaner repos and a better build structure.

## How it works

Add a step to your pipeline and include the pipe like below (replace the values in < >).

```yml
  step:
    name: Deploy to WP Engine
    script:
      - pipe: docker://grafikdev/wpengine-pipe:latest
        variables:
          WPE_API_USER: $WPE_API_USER ######### these three need
          WPE_API_PASSWORD: $WPE_API_PASSWORD # to be added to 
          WPE_INSTALL_ID: $WPE_INSTALL_ID ##### Repository variables
          WPE_REPO_URL: git@git.wpengine.com:production/<wpe_repo>.git
          GIT_EMAIL: <git_email> # notified of backup
          GIT_NAME: <git_name> # can be anything
          ARTIFACT: temp.zip # must be a zip file
```

The script will create a backup of your site before pushing. After that it will unzip the artifact and push it to the repo forcefully.

## Tips

- Backup notificaitons are sent to the git email
- You can get the install ID by via the wpengine API.
