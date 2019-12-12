# Commands used during survey creation

cmd__install() {
    # Install Python package
    pip3 install -U "$@"
    python3 $DIR/content/update_requirements.py "$@"
}

cmd__shell() {
    # Run Hemlock shell
    export `python3 $DIR/env/export_yaml.py env/local-env.yaml`
    flask shell
}

cmd__run() {
    # Run Hemlock app locally
    export `python3 $DIR/env/export_yaml.py env/local-env.yaml`
    python3 app.py
}

cmd__rq() {
    # Run Hemlock Redis Queue locally
    export `python3 $DIR/env/export_yaml.py env/local-env.yaml`
    rq worker hemlock-task-queue
}

cmd__debug() {
    # Run debugger
    export `python3 $DIR/env/export_yaml.py env/local-env.yaml`
    code="from hemlock.debug import AIParticipant, main; \\
        main($num_batches, $batch_size)"
    if [ $local = True ]; then
        python3 -c"$code"
    else
        heroku run python -c"$code"
    fi
}