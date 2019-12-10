# Initialize Hemlock project

cmd__init() {
    # Initialize Hemlock project
    echo "Initializing Hemlock project"
    export `python3 $DIR/env/export_yaml.py $DIR/env/config.yaml`
    create_gcloud_project
    clone_hemlock_template
    copy_env_files
    create_gcloud_service_account
    create_gcloud_buckets
    export_env_variables
}

create_gcloud_project() {
    # Create gcloud project associated with Hemlock project
    echo
    echo "Creating gcloud project"
    project_id=`python3 $DIR/gcloud/gen_id.py $project`
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
    echo "  $DIR/env/local-env.yaml --> env/local-env.yaml"
    cp $DIR/env/local-env.yaml .
    echo "  $DIR/env/production-env.yaml --> env/production-env.yaml"
    cp $DIR/env/production-env.yaml .
    cd ..
}

create_gcloud_service_account() {
    # Create gcloud project owner service account
    echo
    echo "Creating gcloud project service account"
    owner=$project-owner
    echo "  Creating service account $owner as owner of project $project_id"
    gcloud iam service-accounts create $owner --project $project_id
    gcloud projects add-iam-policy-binding $project_id \
        --member "serviceAccount:$owner@$project_id.iam.gserviceaccount.com" \
        --role "roles/owner"
    gcloud iam service-accounts keys create env/gcp-credentials.json \
        --iam-account $owner@$project_id.iam.gserviceaccount.com
}

create_gcloud_buckets() {
    # Create gcloud buckets
    echo
    echo "Creating gcloud buckets"
    local_bucket=`python3 $DIR/gcloud/gen_id.py $project-local-bucket`
    echo "  Making local bucket $local_bucket"
    gsutil mb -p $project_id gs://$local_bucket
    gsutil cors set $DIR/gcloud/cors.json gs://$local_bucket
    bucket=`python3 $DIR/gcloud/gen_id.py $project-bucket`
    echo "  Making production bucket $bucket"
    gsutil mb -p $project_id gs://$bucket
}

export_env_variables() {
    # Export project environment variables
    echo
    echo "Exporting environment variables"
    python3 $DIR/hlk.py export FLASK_APP=app
    python3 $DIR/hlk.py export \
        GOOGLE_APPLICATION_CREDENTIALS=env/gcp-credentials.json
    python3 $DIR/hlk.py export BUCKET=$local_bucket --local
    python3 $DIR/hlk.py export BUCKET=$bucket --prod
}