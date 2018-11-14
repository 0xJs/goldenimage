#!/bin/bash
# make newline the only seperator for the txt files
IFS=$'\n'

# Variable for the current path, so the scripts saves the log files in the same file
scriptpath=$(pwd)
scriptpathlogs=$scriptpath/logs
listpath=$scriptpath/lists

# Variables for the logfiles. Made with the date and time
updatelog="$scriptpath/logs/log_update$(date +%Y-%m-%d_%H:%M).log"
aptlog="$scriptpath/logs/log_apt$(date +%Y-%m-%d_%H:%M).log"
gitlog="$scriptpath/logs/log_git$(date +%Y-%m-%d_%H:%M).log"

# $0 to call the name of the script
usage="Usage: $0 [-u] [-i] [-g] [-r]
	[-u] To update and upgrade the system and update all github repositories
             listed in githubrepos.txt that do exist in /opt.
	[-i] To update & upgrade the system and install all packages listed in
             kaliui.tx and packages.txt
	[-g] To clone and update all github repositories in githubrepos.txt to /opt
	[-r] To restart the system after completion of the script

If you got a clean kali light system use $0 -igr"

check_git (){
  # Check if git is installed, if not then install git.
  echo ---------------------------------------------------------------------------;
  echo --------------------Checking if git is installed---------------------------;
  echo ---------------------------------------------------------------------------;

  if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    # -q for only redirecting errors
    apt-get -qq install git -y &>> "$aptlog";
    echo Git is succesfully installed;
  else
    echo Git is already installed | tee -a "$aptlog";
  fi
}

apt_update (){
  echo ---------------------------------------------------------------------------;
  echo -----------------------Updating and upgrading the system-------------------;
  echo ---------------------------------------------------------------------------;
  echo Updating;
  # Redirect output of update to a logfile for update
  apt update -y &>> "$updatelog";
  echo Upgrading;
  # Redirect output of upgrade to a logile for update
  apt full-upgrade -y &>> "$updatelog";
}

# Print usage if no arguments where given
if [[ $# -eq 0 ]] ; then
    echo "$usage";
    exit 0
fi

# Make directory named logs in the path where the script is, if it does not exist yet
if [ ! -d $scriptpathlogs ]; then
    cd $scriptpath
    mkdir logs
fi

# While loop for al the options
while getopts ':uigr' opt; do
  case "$opt" in
    u)
      #calling the check apt_update function to have its code executed
      apt_update

      #calling the check_git function to have its code executed
      check_git

      # Will go through all the github repositories listed in githubrepos.txt. If they are found in /opt
      # They will be updated with git pull. For downloading check [g].
      echo ---------------------------------------------------------------------------;
      echo ----------------Updatding GitHub Repositories in /opt----------------------;
      echo ---------------------------------------------------------------------------;

      for repos in $(cat $listpath/githubrepos.txt)
        do
          # tr -d '\r' for removing the ^m carriage return
          localrepodir=`echo ${repos##*/} | tr -d '\r'`
          if [ -d /opt/$localrepodir ] ; then
            cd /opt/$localrepodir;
            echo $localrepodir >> "$gitlog";
            git pull &>> "$gitlog";
            echo $localrepodir exists, updated tool with git pull command;
          else
            echo $localrepodir does not exist, please run [-g] to clone the tools | tee -a "$gitlog";
          fi
      done
      ;;
    i)
     #calling the check apt_update function to have its code executed
     apt_update

     # Will check if the kali UI is already installed, if not then it will install it with apt install.
      echo ---------------------------------------------------------------------------;
      echo -----Starting the install of the Kali UI packages listed in kaliui.txt-----;
      echo ---------------------------------------------------------------------------;

      for kaliui in $(cat $listpath/kaliui.txt);
       do
         if [ $(dpkg-query -W -f='${Status}' $kaliui 2>/dev/null | grep -c "ok installed") -eq 0 ] ; then
           # Debian_frontend... for not having to click yes & -q for only redirecting errors
           # If the apt install exits with not 0 (not succeeded) it will print installation failed
             DEBIAN_FRONTEND=noninteractive apt -qq install $kaliui -y &>> "$aptlog"\
		   && echo $kaliui is succesfully installed | tee -a "$aptlog"\
		   || echo $kaliui Installation failed | tee -a "$aptlog";
         else
           echo $kaliui is already installed | tee -a "$aptlog";
         fi
       done

      # Will check if the package is already installed, if not then it will install it with apt install.
      # If the apt install exits with not 0 (not succeeded) it will print Installation failed
      echo ---------------------------------------------------------------------------;
      echo ------Starting the install of all packages listed in packages.txt----------;
      echo ---------------------------------------------------------------------------;

      for package in $(cat $listpath/packages.txt);
        do
          if [ $(dpkg-query -W -f='${Status}' $package 2>/dev/null | grep -c "ok installed") -eq 0 ] ; then
            #Debian_frontend... for not having to click yes & -q for only redirecting errors
            #If the apt install exits with not 0 (not succeeded) it will print installation failed
            DEBIAN_FRONTEND=noninteractive apt -qq install $package -y &>> "$aptlog" 2>&1\
		    && echo $package is succesfully installed | tee -a "$aptlog"\
		    || echo $package Installation failed | tee -a  "$aptlog";
          else
            echo $package is already installed | tee -a "$aptlog";
          fi
        done
      ;;
    g)
      #Calling the check_git function to have its code executed
      check_git

      # Will go through all the github repositories listed in githubrepos.txt. If they are found in /opt
      # They will be updated with git pull, if they arent in /opt they will be cloned to /opt
      echo ---------------------------------------------------------------------------;
      echo ----------------Installing GitHub Repositories in /opt---------------------;
      echo ---------------------------------------------------------------------------;

      for repos in $(cat $listpath/githubrepos.txt)
        do
          # tr -d '\r' for removing the ^m carriage return
          localrepodir=`echo ${repos##*/} | tr -d '\r'`
          if [ -d /opt/$localrepodir ] ; then
            cd /opt/$localrepodir;
            echo $localrepodir >> "$gitlog";
            git pull &>> "$gitlog";
            echo $localrepodir already exists, updated tool with git pull;
          else
            cd /opt;
            # --progress and 2> for redirecting output to logfile
            git clone --progress $repos 2> "$gitlog";
            echo $localrepodir Tool is cloned to /opt | tee -a "$gitlog";
          fi
        done
      ;;
    r)
      echo ---------------------------------------------------------------------------;
      echo ----------------Restarting the system in 10 seconds------------------------;
      echo ---------------------------------------------------------------------------;
      sleep 10;
      reboot;
      ;;
    h)
      echo "$usage";
      ;;
    \?)
      echo "$usage";
      ;;
  esac
done
