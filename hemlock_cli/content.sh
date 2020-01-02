# Commands used during survey creation

cmd__install() {
    # Install Python package
    pip3 install -U "$@"
    python3 $DIR/content/update_requirements.py "$@"
}

set_local_env() {
    # Set local environment variables
    export `python3 $DIR/env/export_yaml.py env/local-env.yaml`
}

cmd__shell() {
    # Run Hemlock shell
    set_local_env
    flask shell
}

cmd__run() {
    # Run Hemlock app locally
    set_local_env
    python3 app.py $debug
}

cmd__rq() {
    # Run Hemlock Redis Queue locally
    set_local_env
    rq worker hemlock-task-queue
}

cmd__debug() {
    # Run debugger
    code="from hemlock.debug import AIParticipant, debug; \\
        debug($num_batches, $batch_size)"
    if [ $local = True ]; then
        set_local_env
        python3 -c"$code"
    else
        heroku run python -c"$code"
    fi
}