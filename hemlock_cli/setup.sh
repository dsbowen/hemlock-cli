# Install recommended software

cmd__setup() {
    if [ $vscode = 'True' ]; then {
        vscode 
    }
    fi
    if [ $heroku_cli = 'True' ]; then {
        heroku_cli
    }
    fi
    if [ $git = 'True' ]; then {
        git_setup
    }
    fi
    if [ $chrome = 'True' ]; then {
        chrome
    }
}

vscode() {
    echo
    echo "Installing Visual Studio Code"
    wget -O vscode.deb https://code.visualstudio.com/docs/?dv=linux64_deb
    apt install -f -y ./vscode.deb
}

heroku_cli() {
    echo
    echo "Installing Heroku-CLI"
    curl https://cli-assets.heroku.com/install.sh | sh
    heroku login
}

git_setup() {
    echo
    echo "Installing git"
    apt install -f -y git
    echo
    echo "If you do not have a github account, go to https://github.com to create one now"
    echo "Enter git username"
    read username
    git config --global user.name $username
    echo "Enter git email"
    read email
    git config --global user.email $email
}

chrome() {
    echo
    echo "Installing google-chrome and chromedriver"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -f -y ./google-chrome-stable_current_amd64.deb
    wget https://chromedriver.storage.googleapis.com/79.0.3945.36/chromedriver_win32.zip
    apt install -f -y unzip
    unzip chromedriver_win32.zip
    echo "About to store chromedriver in Windows user directory"
    echo "Please enter your Windows username to continue"
    read username
    WINHOME=/mnt/c/users/$username
    mkdir $WINHOME/webdrivers
    mv chromedriver.exe $WINHOME/webdrivers/chromedriver
    apt install -f -y gedit
}