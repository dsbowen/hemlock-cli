# Install recommended software

cmd__setup() {
    get_winhome
    utils
    if [[ $vscode = "True" ]]; then {
        vscode 
    }
    fi
    if [[ $heroku_cli = "True" ]]; then {
        heroku_cli
    }
    fi
    if [[ $git = "True" ]]; then {
        git_setup
    }
    fi
    if [[ $chrome = "True" ]]; then {
        chrome
    }
    fi
    if [[ $cloud_sdk = "True" ]]; then {
        cloud_sdk
    }
    fi
}

get_winhome() {
    echo "Enter your Windows username"
    read username
    echo "Confirm Windows username"
    read confirm
    if [ $username != $confirm ]; then {
        echo "Usernames do not match"
        echo
        get_winhome
    }
    else {
        export WINHOME=/mnt/c/users/$username
    }
    fi
}

utils() {
    # apt install other Hemlock utilities
    sudo apt install -f -y python3-venv
    sudo apt install -f -y redis-server
    sudo service redis-server start
}

# vscode() {
#     echo
#     echo "Installing Visual Studio Code"
#     wget -O vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868
#     apt install -f -y ./vscode.deb
# }

vscode() {
    echo
    echo "Installing Visual Studio Code"
    wget -O $WINHOME/vscode-setup.exe https://aka.ms/win32-x64-user-stable
    $WINHOME/vscode-setup.exe
}

heroku_cli() {
    echo
    echo "Installing Heroku-CLI"
    curl https://cli-assets.heroku.com/install.sh | sh
    heroku login
}

git_setup() {
    echo
    echo "Installing Git"
    apt install -f -y git
    echo
    echo "If you do not have a github account, go to https://github.com to create one now"
    echo "Enter git username"
    read username
    git config --global user.name $username
    echo "Enter email associated with git account"
    read email
    git config --global user.email $email
}

chrome() {
    echo
    echo "Installing Google Chrome and Chromedriver"
    # Google Chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -f -y ./google-chrome-stable_current_amd64.deb
    # Chromedriver
    wget https://chromedriver.storage.googleapis.com/79.0.3945.36/chromedriver_win32.zip
    apt install -f -y unzip
    unzip chromedriver_win32.zip
    mkdir $WINHOME/webdrivers
    mv chromedriver.exe $WINHOME/webdrivers/chromedriver
    python3 $DIR/setup/add_to_path.py $WINHOME/webdrivers
}

cloud_sdk() {
    echo
    echo "Installing Cloud SDK"
    echo "Create a Google Cloud Platform project, if you do not have one already, at https://console.cloud.google.com/cloud-resource-manager"
    echo "Press any key to continue"
    wget -O cloud-sdk-setup.exe https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
    mv cloud-sdk-setup.exe $WINHOME
    $WINHOME/cloud-sdk-setup.exe
}