# Deploy, scale, and destroy project

cmd__deploy() {
    # Deploy application
    echo "Deploying algorithm"
    export `python3 $DIR/env/export_yaml.py env/production-scale.yaml`
    export_lite_vars
    create_app
    create_addons
    if [ $USE_BUCKET != 0 ]; then
        set_bucket_cors
    fi
    push_slug
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
    python3 $DIR/env/update_yaml.py env/production-env.yaml URL_ROOT $URL_ROOT
    heroku config:set \
        `python3 $DIR/env/export_yaml.py env/production-env.yaml`
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
    echo "Setting CORS permissions for production bucket"
    echo "Enabling bucket $BUCKET CORS permissions for origin $URL_ROOT"
    python3 $DIR/gcloud/create_cors.py $URL_ROOT
    gsutil cors set cors.json gs://$BUCKET
    rm cors.json
}

push_slug() {
    # Push Heroku slug
    echo
    echo "Pushing Heroku slug"
    git add .
    if [ $USE_BUCKET != 0 ]; then
        git add -f env/gcp-credentials.json
    fi
    git commit -m "deploying survey"
    git push heroku master
    heroku git:remote -a $app
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
    export `python3 $DIR/env/export_yaml.py env/production-scale.yaml`
    heroku addons:destroy heroku-postgresql
    heroku addons:destroy heroku-redis
    create_addons
    scale
}

cmd__update() {
    # Update application
    echo "Updating application"
    heroku config:set `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    git add .
    git commit -m "update"
    git push heroku master
}

cmd__destroy() {
    # Destroy applicaiton
    echo "Preparing to destroy application"
    export `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    if [ $USE_BUCKET != 0 ]; then
        echo
        echo "Restricting CORS permissions for production bucket"
        python3 $DIR/gcloud/create_cors.py ""
        gsutil cors set cors.json gs://$BUCKET
        rm cors.json
    fi
    echo
    echo "Destroying application"
    heroku apps:destroy
}