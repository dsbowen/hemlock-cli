#!/bin/bash
# Commands used during survey creation

cmd__install() {
    # Install Python package
    pip3 install -U "$@"
    python3 $DIR/content/update_requirements.py "$@"
}

cmd__serve() {
    # Run Hemlock app locally
    echo "Prepare to get served."
    echo
    export_env
    python3 app.py
}

cmd__rq() {
    # Run Hemlock Redis Queue locally
    export_env
    rq worker hemlock-task-queue
}

cmd__debug() {
    # Run debugger
    code="from hemlock.debug import AIParticipant, debug; \\
        debug($2, $3)"
    if [ $1 = True ]; then
        heroku run python -c"$code"
    else
        export_env
        python3 -c"$code"
    fi
}

export_env() {
    # Export local environment variables
    export `python3 $DIR/env/export_yml.py env/local-env.yml`
}