#!/bin/bash

# Directory of current sh file (and config and default env files)
DIR=`dirname $0`

hlk__config() {
    # Set configuration variable
    local assignment=$1
    python3 $DIR/update_yaml.py $DIR/config.yaml $assignment
}

hlk__export() {
    # Set environment variable
    local assignment=$1
    local local_env=$2
    local prod_env=$3
    local default=$4
    if [ $local_env = 1 ]; then
        if [ $default = 1 ]; then
            yaml_path=$DIR/local-env.yaml
        else
            yaml_path=env/local-env.yaml
        fi
        python3 $DIR/update_yaml.py $yaml_path $assignment
    fi
    if [ $prod_env = 1 ]; then
        if [ $default = 1 ]; then
            yaml_path=$DIR/production-env.yaml
        else
            yaml_path=env/production-env.yaml
        fi
        python3 $DIR/update_yaml.py $yaml_path $assignment
    fi
}

hlk__init() {
    # Initialize Hemlock project
    project=$1
    echo "Initializing Hemlock project"
    export `python3 $DIR/export_yaml.py $DIR/config.yaml`
    create_gcloud_project
    clone_hemlock_template
    copy_env_files
    make_gcloud_buckets
    export_env_variables
}

create_gcloud_project() {
    # Create gcloud project associated with Hemlock project
    echo
    echo "Creating gcloud project"
    project_id=`python3 $DIR/gen_id.py $project`
    gcloud projects create $project_id --name $project
    gcloud alpha billing projects link $project_id \
        --billing-account $GCLOUD_BILLING_ACCOUNT
}

clone_hemlock_template() {
    # Clone Hemlock template and set up hemlock-venv
    echo
    echo "Cloning Hemlock template from $HEMLOCK_TEMPLATE_URL"
    git clone $HEMLOCK_TEMPLATE_URL $project
    cd $project
    git remote rm origin
    echo "Creating virtual environment"
    python3 -m venv hemlock-venv
    echo "Installing local requirements"
    pip3 install -r local-requirements.txt
}

copy_env_files() {
    # Copy environment files to the project directory
    echo
    echo "Copying environment files to project directory"
    mkdir env
    cd env
    echo "  $DIR/local-env.yaml --> env/local-env.yaml"
    cp $DIR/local-env.yaml .
    echo "  $DIR/production-env.yaml --> env/production-env.yaml"
    cp $DIR/production-env.yaml .
    cd ..
}

make_gcloud_buckets() {
    # Make gcloud project owner service account and buckets
    echo
    echo "Making gcloud buckets"
    owner=$project-owner
    echo "  Creating service account $owner as owner of project $project_id"
    gcloud iam service-accounts create $owner --project $project_id
    gcloud projects add-iam-policy-binding $project_id \
        --member "serviceAccount:$owner@$project_id.iam.gserviceaccount.com" \
        --role "roles/owner"
    gcloud iam service-accounts keys create env/gcp-credentials.json \
        --iam-account $owner@$project_id.iam.gserviceaccount.com
    local_bucket=`python3 $DIR/gen_id.py $project-local-bucket`
    echo "  Making local bucket $local_bucket"
    gsutil mb -p $project_id gs://$local_bucket
    gsutil cors set $DIR/cors.json gs://$local_bucket
    bucket=`python3 $DIR/gen_id.py $project-bucket`
    echo "  Making production bucket $bucket"
    gsutil mb -p $project_id gs://$bucket
}

export_env_variables() {
    # Export project environment variables
    echo
    echo "Exporting environment variables"
    hlk__export FLASK_APP=app 1 0 0
    hlk__export \
        GOOGLE_APPLICATION_CREDENTIALS=env/gcp-credentials.json 1 1 0
    hlk__export BUCKET=$local_bucket 1 0 0
    hlk__export BUCKET=$bucket 0 1 0
}

hlk__install() {
    # Install Python package
    pip3 install -U "$@"
    python3 $DIR/update_requirements.py "$@"
}

hlk__shell() {
    # Run Hemlock shell
    export `python3 $DIR/export_yaml.py env/local-env.yaml`
    flask shell
}

hlk__run() {
    # Run Hemlock app locally
    export `python3 $DIR/export_yaml.py env/local-env.yaml`
    python3 app.py
}

hlk__rq() {
    # Run Hemlock Redis Queue locally
    export `python3 $DIR/export_yaml.py env/local-env.yaml`
    rq worker hemlock-task-queue
}

hlk__deploy() {
    # Deploy application
    app=$1
    export `python3 $DIR/export_yaml.py env/production-env.yaml`
    verify_current_env local
    echo "Deploying algorithm"
    create_app
    set_bucket_cors
    push_slug
    lite_scale
    hlk__export CURRENT_ENV=production-lite 1 1 0
}

verify_current_env() {
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
    heroku config:set `python3 $DIR/export_yaml.py env/production-env.yaml`
    heroku buildpacks:add heroku/python
    # heroku buildpacks:add $WKHTMLTOPDF_BUILDPACK_URL
    heroku buildpacks:add $GOOGLE_CHROME_BUILDPACK_URL
    heroku buildpacks:add $CHROMEDRIVER_BUILDPACK_URL
}

set_bucket_cors() {
    # Set production bucket CORS permissions
    echo
    echo "Setting CORS permissions for production bucket"
    origin=http://$app.herokuapp.com
    echo "Enabling bucket $BUCKET CORS permissions for origin $origin"
    python3 $DIR/create_cors.py $origin
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

lite_scale() {
    # Scale application for production-lite environment
    echo
    echo "Scaling application for production-lite environment"
    postgres_plan=hobby-dev
    redis_plan=hobby-dev
    proc_type=free
    web_proc_scale=1
    if [ $WORKER = 1 ]; then
        worker_proc_scale=1
    else
        worker_proc_scale=1
    fi
    scale
}

scale() {
    # Scale application
    heroku addons:add heroku-postgresql:$postgres_plan
    heroku addons:add heroku-redis:$redis_plan
    heroku ps:type $proc_type
    heroku ps:scale web=$web_proc_scale
    heroku ps:scale worker=$worker_proc_scale
}

hlk__production() {
    # Convert to production environment
    # upgrade addons and scale dynos
    export `python3 $DIR/export_yaml.py env/production-env.yaml`
    verify_current_env production-lite
    echo "About to convert to production environment"
    echo "WARNING: This action will override the current database"
    echo "Confirm the application name below to proceed"
    echo
    heroku addons:destroy heroku-postgresql
    heroku addons:destroy heroku-redis  
    production_scale
    hlk__export CURRENT_ENV=production 1 1 0
}

production_scale() {
    echo
    echo "Scaling application for production environment"
    postgres_plan=standard-0
    proc_type=standard-1x
    web_proc_scale=3
    if [ $WORKER = 1 ]; then
        redis_plan=premium-1
        worker_proc_scale=3
    else
        redis_plan=hobby-dev
        worker_proc_scale=1
    fi
    scale
}

hlk__update() {
    # Update application
    echo "Updating application"
    heroku config:set `python3 $DIR/export_yaml.py env/production-env.yaml`
    git add .
    git commit -m "update"
    git push heroku master
}

hlk__worker() {
    # Turn worker on or off
    worker=$1
    export `python3 $DIR/export_yaml.py env/production-env.yaml`
    if [ $CURRENT_ENV = local ] || [ $worker = $WORKER ]; then
        hlk__export WORKER=$worker 1 1 0
        exit 0
    fi
    modify_worker
    hlk__export WORKER=$worker 1 1 0
}

modify_worker() {
    # Modify worker for current application
    if [ $worker = 1 ]; then
        echo "Creating worker"
        if [ $CURRENT_ENV = production ]; then
            heroku addons:destroy heroku-redis
            heroku addons:add heroku-redis:premium-1
            heroku ps:scale worker=3
        else
            heroku ps:scale worker=1
        fi
    else
        echo "Destroying worker"
        if [ $CURRENT_ENV = production ]; then
            heroku addons:destroy heroku-redis
            heroku addons:add heroku-redis:hobby-dev
        fi
        heroku ps:scale worker=0
    fi
}

hlk__destroy() {
    # Destroy applicaiton
    echo "Preparing to destroy application"
    echo
    echo "Restricting CORS permissions for production bucket"
    export `python3 $DIR/export_yaml.py env/production-env.yaml`
    python3 $DIR/create_cors.py ""
    gsutil cors set cors.json gs://$BUCKET
    echo
    echo "Destroying application"
    heroku apps:destroy
    hlk__export CURRENT_ENV=local 1 1 0
}

hlk() {
    local cmd=$1
    shift
    "hlk__$cmd" "$@"
}

hlk "$@"