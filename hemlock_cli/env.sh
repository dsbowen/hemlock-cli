# Export and modify environment variables

cmd__export() {
    # Set environment variables
    modify_env export
}

cmd__unset() {
    # Unset environment variables
    modify_env unset
}

modify_env() {
    # Modify environment variables
    # modify local and production project variables by default
    operation=$1
    if [ $config = False ] && [ $local = False ] && [ $prod = False ]; then
        local=True prod=True
    fi
    if [ $config = True ]; then
        python3 $DIR/env/update_yaml.py $DIR/env/config.yaml $operation
    fi
    if [ $local = True ]; then
        modify_local_env
    fi
    if [ $prod = True ]; then
        modify_prod_env
    fi
}

modify_local_env() {
    # Modify local environmetn variables
    if [ $default = True ]; then
        yaml_path=$DIR/env/local-env.yaml
    else
        yaml_path=env/local-env.yaml
    fi
    python3 $DIR/env/update_yaml.py $yaml_path $operation
}

modify_prod_env() {
    # Modify production environment variables
    if [ $default = True ]; then
        yaml_path=$DIR/env/production-env.yaml
    else
        yaml_path=env/production-env.yaml
    fi
    python3 $DIR/env/update_yaml.py $yaml_path $operation
}