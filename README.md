# Goldenimage

## Description
This script is written for a internship and used for upgrading a kali light system to their environment. But it may be usefull if you are looking for a script to update your environment. You just need to edit the .txt files to your desires.

## Usage
./golden_image.sh [-u] [-i] [-g] [-r]
[-u] To update and upgrade the system and to update all GitHub repositories listed in githubrepos.txt that do exist in /opt 
[-i] To update & upgrade and install packages listed in kaliui.txt and packages.txt 
[-g] To clone and update all GitHub repositories in githubrepos.txt to /opt 
[-r] To restart the system after completion of the script
[-s] To shutdown the system after completion of the script

If you got a clean kali light system use ./golden_image.sh -igr


### Example
Just update the system with apt-update, apt-upgrande and git pull all packages listed in githubrepos.txt
```sh
./golden_image.sh -u
```

Install all packages in packages.txt, kaliui.txt and clone all repositories listed in githubrepos.txt
```sh
./golden_image.sh -i -g
```


