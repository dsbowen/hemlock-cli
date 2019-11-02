#!/bin/bash

# URL of Hemlock template
HEMLOCK_URL=https://github.com/dsbowen/hemlock.git

hlk__init() {
    # Initialize Hemlock project
    local path=$1
    echo "Initializing Hemlock project"
    echo "Cloning Hemlock template from $HEMLOCK_URL"
    git clone $HEMLOCK_URL $path
    cd $path
    git remote rm origin
    echo "Creating virtual environment"
    python3 -m venv hemlock-venv
    echo "Installing local requirements"
    pip3 install -r local-requirements.txt
}

hlk__deploy() {
    # Deploy application
    local app=$1
    shift
    get_heroku_args "$@"
    echo "Deploying algorithm"
    echo "Environment: $mode"
    git init
    git add .
    git commit -m "deploying survey"
    heroku apps:create $app
    git push heroku master
    scale_heroku
    heroku git:remote -a $app
}

hlk__production() {
    # Convert to production environment
    # upgrade database and scale dynos
    echo "About to convert to production environment"
    echo "WARNING: This action will override the current database"
    echo "Confirm the application name below to proceed"
    echo
    heroku addons:destroy heroku-postgresql
    get_heroku_args 1 "$@"    
    scale_heroku
}

get_heroku_args() {
    # Get heroku postgres plan, process types, and dyno scaling
    local production=$1
    local worker=$2
    worker_proc_scale=0
    if [ $production = 1 ]; then
        mode="production"
        postgres_plan="standard-0"
        proc_type="standard-2x"
        web_proc_scale=3
        if [ $worker = 1 ]; then
            worker_proc_scale=3
        fi
    else
        mode="debugging"
        postgres_plan="hobby-dev"
        proc_type="free"
        web_proc_scale=1
        if [ $worker = 1 ]; then
            worker_proc_scale=1
        fi
    fi
}

scale_heroku() {
    # Scale application
    heroku addons:add heroku-postgresql:$postgres_plan
    heroku pg:wait
    heroku ps:scale web=$web_proc_scale:$proc_type
    heroku ps:scale worker=$worker_proc_scale:$proc_type
}

hlk__update() {
    # Update application
    echo "Updating application"
    git add .
    git commit -m "update"
    git push heroku master
}

hlk__destroy() {
    # Destroy applicaiton
    echo "About to destroy application"
    echo "WARNING: You will be unable to access your data through the application after this action"
    echo "Download your data before proceeding"
    echo
    heroku apps:destroy
}

hlk() {
    local cmd=$1
    shift
    "hlk__$cmd" "$@"
}

hlk "$@"