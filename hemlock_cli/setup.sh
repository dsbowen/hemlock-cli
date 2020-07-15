#!/bin/bash
# Setup for recommended software

cmd__setup() {
    export OS=$1
    if [ $2 = True ]; then git_setup; fi
    if [ $3 = True ]; then chrome_setup; fi
    if [ $4 = True ]; then chromedriver_setup; fi
    if [ $5 = True ]; then heroku_cli_setup; fi
    echo
    echo "Installation complete. You may need to close and re-open your terminal."
}

redis() {
    # Start redis server
    apt install -f -y redis-server
    sudo service redis-server start
}

git_setup() {
    echo
    if [ $OS = 'win' ]; then
        echo "Download git from https://git-scm.com/download/win"
        return
    elif [ $OS = 'wsl' ]; then
        echo "Installing Git"
        apt install -f -y git
    fi
    echo
    echo "If you do not have a github account, go to https://github.com to create one now"
    echo "Enter git username"
    read username
    git config --global user.name $username
    echo "Enter email associated with git account"
    read email
    git config --global user.email $email
}

chrome_setup() {
    # set chrome as the default browser
    if [ $OS = win ]; then
        # shouldn't have to do this on win, but it won't hurt
        python3 $DIR/add_bashrc.py \
            "export BROWSER=\"/c/program files (x86)/google/chrome/application/chrome.exe\""
    elif [ $OS = wsl ]; then
        python3 $DIR/add_bashrc.py \
            "export BROWSER=\"/mnt/c/program files (x86)/google/chrome/application/chrome.exe\""
    fi
}

chromedriver_setup() {
    get_winhome
    echo
    echo "Installing Chromedriver"
    curl -o chromedriver_win32.zip \
        https://chromedriver.storage.googleapis.com/83.0.4103.39/chromedriver_win32.zip
    apt install -f -y unzip
    unzip chromedriver_win32.zip
    rm chromedriver_win32.zip
    if [ ! -d $WINHOME/webdrivers ]; then mkdir $WINHOME/webdrivers; fi
    if [ $OS = win ]; then
        mv chromedriver.exe $WINHOME/webdrivers
    elif [ $OS = wsl ]; then
        # make sure executable is 'chromedriver' not 'chromedriver.exe'
        mv chromedriver.exe $WINHOME/webdrivers/chromedriver
    fi
    # if [[ ":$PATH:" != *":$WINHOME/webdrivers:"* ]]; then
        # NOTE: for some reason this doesn't recognize that chromedriver is in path in WSL
        # works fine in the ubuntu terminal and git bash, but not here
        # this will add the chromedriver path to the bashrc multiple times
        # also, [[ isn't recognized by git bash
    python3 $DIR/add_bashrc.py \
        "export PATH=\"$WINHOME/webdrivers:\$PATH\""
    # fi
}

get_winhome() {
    echo 
    echo "Enter your Windows username"
    read username
    echo "Confirm Windows username"
    read confirm
    if [ $username != $confirm ]; then
        echo "Usernames do not match"
        echo
        get_winhome
    else {
        if [ $OS = 'win' ]; then
            export WINHOME=/c/users/$username
        elif [ $OS = 'wsl' ]; then
            export WINHOME=/mnt/c/users/$username
        fi
    }
    fi
}

heroku_cli_setup() {
    echo
    if [ $OS = win ]; then
        echo "Download the heroku CLI from https://devcenter.heroku.com/articles/heroku-cli"
        return
    elif [ $OS = wsl ]; then
        echo "Installing Heroku-CLI"
        curl https://cli-assets.heroku.com/install.sh | sh
    fi
    echo "Opening Heroku login page"
    echo "  NOTE: You may have to open this page manually"
    heroku login
}