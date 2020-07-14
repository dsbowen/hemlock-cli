# Deploy, scale, and destroy project

cmd__deploy() {
    # Deploy application
    echo "Deploying algorithm"
    export `python3 $DIR/env/export_yml.py env/production-env.yml`
    export `python3 $DIR/env/export_yml.py env/production-scale.yml`
    export_lite_vars
    create_app
    create_addons
    set_bucket_cors
    push_slug
    heroku git:remote -a $app
    scale
}

export_lite_vars() {
    # Export production lite variables
    export POSTGRES_PLAN=hobby-dev \
        REDIS_PLAN=hobby-dev \
        WEB_PROCTYPE=free \
        WEB_SCALE=1 \
        WORKER_PROCTYPE=free
    if [ $WORKER_SCALE != 0 ]; then
        export WORKER_SCALE=1
    fi
}

create_app() {
    # Create Heroku app
    echo
    echo "Creating application"
    heroku apps:create $app
    URL_ROOT=http://$app.herokuapp.com
    python3 $DIR/env/update_yml.py env/production-env.yml URL_ROOT $URL_ROOT
    heroku buildpacks:add heroku/python
    heroku buildpacks:add https://github.com/heroku/heroku-buildpack-chromedriver
    heroku buildpacks:add https://github.com/heroku/heroku-buildpack-google-chrome
}

create_addons() {
    # Create postgres and redis addons
    echo
    echo "Creating postgres and redis addons"
    heroku addons:add heroku-postgresql:$POSTGRES_PLAN
    if [ $WORKER_SCALE != 0 ]; then
        heroku addons:add heroku-redis:$REDIS_PLAN
    fi
}

set_bucket_cors() {
    # Set production bucket CORS permissions
    echo
    if [ -z "$BUCKET" ]; then
        echo "No bucket detected"
        return
    fi
    echo "Setting CORS permissions on bucket $BUCKET for origin $URL_ROOT"
    python3 $DIR/gcloud/create_cors.py $URL_ROOT
    gsutil cors set cors.json gs://$BUCKET
    rm cors.json
}

push_slug() {
    # Push Heroku slug
    echo
    echo "Pushing Heroku slug"
    heroku config:set \
        `python3 $DIR/env/export_yml.py env/production-env.yml`
    git add .
    if [ ! -z "$BUCKET" ]; then
        git add -f env/gcp-credentials.json
    fi
    git commit -m "deploying survey"
    git push -f heroku master
    git reset HEAD^
}

scale() {
    # Create addons and scale
    echo
    echo "Scaling worker and web processes"
    heroku ps:scale \
        web=$WEB_SCALE:$WEB_PROCTYPE \
        worker=$WORKER_SCALE:$WORKER_PROCTYPE
}

cmd__production() {
    # Convert to production environment
    # upgrade addons and scale dynos
    echo "About to convert to production environment"
    echo "WARNING: This action will override the current database"
    echo "Confirm the application name below to proceed"
    echo
    export `python3 $DIR/env/export_yml.py env/production-scale.yml`
    heroku config:set NO_DEBUG_FUNCTIONS=1
    heroku addons:destroy heroku-postgresql
    heroku addons:destroy heroku-redis
    create_addons
    scale
    heroku certs:auto:enable
}

cmd__update() {
    # Update application
    echo "Updating application"
    export `python3 $DIR/env/export_yml.py env/production-env.yml`
    set_bucket_cors
    push_slug
}

cmd__restart() {
    # Restart application
    echo "Restarting application"
    export `python3 $DIR/env/export_yml.py env/production-env.yml`
    set_bucket_cors
    heroku restart
}

cmd__destroy() {
    # Destroy applicaiton
    echo "Preparing to destroy application"
    python3 $DIR/env/update_yml.py env/production-env.yml URL_ROOT ""
    export `python3 $DIR/env/export_yml.py env/production-env.yml`
    set_bucket_cors
    echo
    echo "Destroying application"
    heroku apps:destroy
}