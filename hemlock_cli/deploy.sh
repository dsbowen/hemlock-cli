# Deploy, scale, and destroy project

cmd__deploy() {
    # Deploy application
    export `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    verify_current_env local
    echo "Deploying algorithm"
    create_app
    create_addons
    set_bucket_cors
    push_slug
    scale
    python3 $DIR/hlk.py export CURRENT_ENV=production-lite
}

verify_current_env() {
    # Verify that the current environment is correct
    local required_env=$1
    if [ $CURRENT_ENV != $required_env ]; then
        echo "Application already in production."
        echo "  To update the current application, use 'hlk update'."
        echo "  To deploy a new application, first destroy the current application with 'hlk destroy'."
        exit 1
    fi
}

create_app() {
    # Create Heroku app
    echo
    echo "Creating application"
    heroku apps:create $app
    heroku config:set `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    heroku buildpacks:add heroku/python
    heroku buildpacks:add $GOOGLE_CHROME_BUILDPACK_URL
    heroku buildpacks:add $CHROMEDRIVER_BUILDPACK_URL
}

create_addons() {
    # Create addons
    echo
    echo "Creating postgres and redis addons"
    if [ $CURRENT_ENV = local ]; then
        postgres_plan=hobby-dev redis_plan=hobby-dev
    else
        postgres_plan=$POSTGRES_PRODUCTION_PLAN
        if [ $WORKER = True ]; then
            redis_plan=$REDIS_PRODUCTION_PLAN
        else
            redis_plan=hobby-dev
        fi
    fi
    heroku addons:add heroku-postgresql:$postgres_plan
    heroku addons:add heroku-redis:$redis_plan
}

scale() {
    # Create addons and scale
    echo
    echo "Scaling worker and web processes"
    if [ $CURRENT_ENV = local ]; then
        proc_type=free web_proc_scale=1 worker_proc_scale=1
    else
        proc_type=$PROCTYPE_PRODUCTION web_proc_scale=$WEB_PRODUCTION_SCALE
        if [ $WORKER = True ]; then
            worker_proc_scale=$WORKER_PRODUCTION_SCALE
        else
            worker_proc_scale=1
        fi
    fi
    heroku ps:type $proc_type
    heroku ps:scale web=$web_proc_scale
    heroku ps:scale worker=$worker_proc_scale
}

set_bucket_cors() {
    # Set production bucket CORS permissions
    echo
    echo "Setting CORS permissions for production bucket"
    origin=http://$app.herokuapp.com
    echo "Enabling bucket $BUCKET CORS permissions for origin $origin"
    python3 $DIR/gcloud/create_cors.py $origin
    gsutil cors set cors.json gs://$BUCKET
}

push_slug() {
    # Push Heroku slug
    echo
    echo "Pushing Heroku slug"
    git add .
    git commit -m "deploying survey"
    git push heroku master
    heroku git:remote -a $app
}

cmd__production() {
    # Convert to production environment
    # upgrade addons and scale dynos
    export `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    verify_current_env production-lite
    echo "About to convert to production environment"
    echo "WARNING: This action will override the current database"
    echo "Confirm the application name below to proceed"
    echo
    heroku addons:destroy heroku-postgresql
    heroku addons:destroy heroku-redis
    create_addons
    scale
    python3 $DIR/hlk.py export CURRENT_ENV=production
}

cmd__update() {
    # Update application
    echo "Updating application"
    heroku config:set `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    git add .
    git commit -m "update"
    git push heroku master
}

cmd__worker() {
    # Turn worker on or off
    worker=$on
    export `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    if [ $CURRENT_ENV = local ] || [ $worker = $WORKER ]; then
        python3 $DIR/hlk.py export WORKER=$worker
        exit 0
    fi
    modify_worker
    python3 $DIR/hlk.py export WORKER=$worker
}

modify_worker() {
    # Modify worker for current application
    if [ $worker = True ]; then
        echo "Creating worker"
        if [ $CURRENT_ENV = production ]; then
            heroku addons:destroy heroku-redis
            heroku addons:add heroku-redis:$REDIS_PRODUCTION_PLAN
            heroku ps:scale worker=$WORKER_PRODUCTION_SCALE
        else
            heroku ps:scale worker=1
        fi
    else
        echo "Scaling down worker"
        if [ $CURRENT_ENV = production ]; then
            heroku addons:destroy heroku-redis
            heroku addons:add heroku-redis:hobby-dev
        fi
        heroku ps:scale worker=1
    fi
}

cmd__destroy() {
    # Destroy applicaiton
    echo "Preparing to destroy application"
    echo
    echo "Restricting CORS permissions for production bucket"
    export `python3 $DIR/env/export_yaml.py env/production-env.yaml`
    python3 $DIR/gcloud/create_cors.py ""
    gsutil cors set cors.json gs://$BUCKET
    echo
    echo "Destroying application"
    heroku apps:destroy
    python3 $DIR/hlk.py export CURRENT_ENV=local
}