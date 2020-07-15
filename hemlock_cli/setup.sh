#!/bin/bash
# Setup for recommended software

cmd__setup() {
    export OS=$1
    if [ $2 = True ]; then git_setup; fi
    if [ $3 = True ]; then chrome_setup; fi
    if [ $4 = True ]; then chromedriver_setup; fi
    if [ $5 = True ]; then heroku_cli_setup; fi
}

redis() {
    # Start redis server
    apt install -f -y redis-server
    sudo service redis-server start
}

git_setup() {
    if [ $OS = win ]; then
        echo "Download git from https://git-scm.com/download/win"
        return
    elif [ $OS = wsl ] || [ $OS = linux ]; then
        echo "Find download instructions from https://git-scm.com/download/linux"
        return
    fi
    echo "Installing Git"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
    brew install git
    echo
    echo "If you do not have a github account, go to https://github.com to create one now"
    echo "Enter git username"
    read username
    git config --global user.name $username
    echo "Enter email associated with git account"
    read email
    git config --global user.email $email
    echo
    echo "Git installation complete."
}

chrome_setup() {
    # set chrome as the default browser
    # should only have to do this on WSL
    if [ $OS = win ]; then
        # chrome_exe_path="/c/program files (x86)/google/chrome/application/chrome.exe"
        echo "This should not be necessary on Windows"
        return
    elif [ $OS = wsl ]; then
        chrome_exe_path="/mnt/c/program files (x86)/google/chrome/application/chrome.exe"
    elif [ $OS = mac ]; then
        # chrome_exe_path="/applications/google chrome.app/contents/macos/google chrome" 
        echo "This should not be necessary on Mac"
        return
    elif [ $OS = linux ]; then
        # chrome_exe_path=""
        echo "This should not be necessary on Linux"
        return
    fi
    python3 $DIR/add_bashrc.py \
        "export BROWSER=\"$chrome_exe_path\""
    echo
    echo "BROWSER variable set. Close and re-open your terminal."
}

chromedriver_setup() {
    echo "Installing Chromedriver"
    if [ $OS = wsl ]; then get_winhome; fi
    get_chromedriver_file
    if [ $OS = wsl ]; then
        # in WSL, need to install chromedriver in windows home, not WSL home
        # also need to rename chromedriver.exe to chromedriver
        if [ ! -d $WINHOME/webdrivers ]; then mkdir $WINHOME/webdrivers; fi
        mv chromedriver.exe $WINHOME/webdrivers/chromedriver
        python3 $DIR/add_bashrc.py \
            "export PATH=\"$WINHOME/webdrivers:\$PATH\""
    else
        if [ ! -d $HOME/webdrivers ]; then mkdir $HOME/webdrivers; fi
        mv chromedriver $HOME/webdrivers
        python3 $DIR/add_bashrc.py \
            "export PATH=\"$HOME/webdrivers:\$PATH\""
    fi
    echo
    echo "Chromedriver setup complete. Close and re-open your terminal."
}

get_winhome() {
    # get windows home location for WSL installation
    echo 
    echo "Enter your Windows username"
    read username
    echo "Confirm Windows username"
    read confirm
    if [ $username != $confirm ]; then
        echo "Usernames do not match"
        get_winhome
    else
        export WINHOME=/mnt/c/users/$username
    fi
}

get_chromedriver_file() {
    # download and unzip chromedriver file
    if [ $OS = win] || [ $OS = wsl ]; then
        chromedriver_url=https://chromedriver.storage.googleapis.com/83.0.4103.39/chromedriver_win32.zip
    elif [ $OS = mac ]; then
        chromedriver_url=https://chromedriver.storage.googleapis.com/83.0.4103.39/chromedriver_mac64.zip
    elif [ $OS = linux ]; then
        chromedriver_url=https://chromedriver.storage.googleapis.com/83.0.4103.39/chromedriver_linux64.zip
    fi
    curl -o chromedriver.zip $chromedriver_url
    apt install -f -y unzip
    unzip chromedriver.zip
    rm chromedriver.zip
}

heroku_cli_setup() {
    if [ $OS = win ]; then
        echo "Download the heroku CLI from https://devcenter.heroku.com/articles/heroku-cli"
        return
    fi
    echo "Installing Heroku-CLI"
    curl https://cli-assets.heroku.com/install.sh | sh
    echo
    echo "Opening Heroku login page"
    echo "  NOTE: You may have to open this page manually"
    heroku login
    echo
    echo "Heroku-cli setup complete."
}