# Commands used during survey creation

cmd__install() {
    # Install Python package
    pip3 install -U "$@"
    python3 $DIR/install/update_requirements.py "$@"
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