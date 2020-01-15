# Initialize Hemlock project

cmd__init() {
    # Initialize Hemlock project
    echo "Initializing Hemlock project"
    echo
    echo "Cloning Hemlock template from $repo"
    git clone $repo $project
    cd $project
    git remote rm origin
    echo "Creating virtual environment"
    python3 -m venv hemlock-venv
    echo "Installing local requirements"
    pip3 install -r local-requirements.txt
}

cmd__gcloud_bucket() {
    # Create gcloud project associated with Hemlock project
    echo
    echo "Creating gcloud project"
    project=${PWD##*/}
    project_id=`python3 $DIR/gcloud/gen_id.py $project`
    gcloud projects create $project_id --name $project
    gcloud alpha billing projects link $project_id \
        --billing-account $gcloud_billing_account
    create_gcloud_service_account
    create_gcloud_buckets
    python3 $DIR/env/update_yaml.py env/local-env.yaml BUCKET $local_bucket
    python3 $DIR/env/update_yaml.py env/local-env.yaml \
        GOOGLE_APPLICATION_CREDENTIALS 'env/gcp-credentials.json'
    python3 $DIR/env/update_yaml.py env/production-env.yaml BUCKET $bucket
    python3 $DIR/env/update_yaml.py env/production-env.yaml \
        GOOGLE_APPLICATION_CREDENTIALS 'env/gcp-credentials.json'
    python3 $DIR/env/update_yaml.py env/production-scale.yaml USE_BUCKET 1
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