#!/bin/bash

# Made by Gabe Livengood with an hour of Googling and a fair bit of StackOverflow. Meant to help
# me learn a bit of Bash, not for functionality, so if you want to actually use it, I'd recommend
# modifying it to fit your needs or making your own script from scratch.

# WTFPL

# Before running, you should have Docker installed on your system. These instructions worked for me,
# but you might have to find a solution specific to your system:
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-debian-9

# These variables control what other people see in the room browser. Change to whatever you want to.
ROOMNAME="`whoami`'s Smash Dojo"
ROOMDESC="Come play with friends!"
PREFGAME="Super Smash Bros. for 3DS"
PREFGAMEID="00040000000EDF00"
PORT=24872
MEMBERMAX=4
PASSWRD=""
# Follow these instructions to get your token: https://citra-emu.org/wiki/citra-web-service/
TOKEN=""

# Check to see if the user is root so Docker can work.
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root!"
    exit
fi

if [ -n "$TOKEN" ]; then
    echo "You need to put your token into the TOKEN variable."
    exit
fi

# Main script

# Check to see if there is already a Citra Docker container up and running, and stop it if there is.
if ps -A | grep citra-room > /dev/null; then
    echo "Stopping the Citra server Docker container..."
{
    docker stop citra_server
    docker rm citra_server
} &> /dev/null
    echo "Done."

# If there was no Citra Docker container up and running, start it and pass all the arguments in the variables above.
else
    echo "Making the Citra server Docker container with name citra_server."

    # Check to see if there was a variable entry for the password. I know this isn't the best way to do this, so if
    # you know a better way, feel free to make a pull request.
    if [ -n "$PASSWRD" ]; then
        {
        docker rm citra_server
        sudo docker run -d --name citra_server \
            --publish 24872:24872/udp \
            citraemu/citra-multiplayer-dedicated \
            --room-name "$ROOMNAME" \
            --room-description "$ROOMDESC" \
            --preferred-game "$PREFGAME" \
            --preferred-game-id ${PREFGAMEID} \
            --port ${PORT} \
            --max_members ${MEMBERMAX} \
            --password "$PASSWRD" \
            --token ${TOKEN} \
            --enable-citra-mods \
            --web-api-url https://api.citra-emu.org/
        } &> /dev/null
        echo "Server started! Here are the room stats.
======================================================
    Room Name:         ${ROOMNAME}
    Room Description:  ${ROOMDESC}
    Preferred Game:    ${PREFGAME}
    Preferred Game ID: ${PREFGAMEID}
    Port:              ${PORT}
    Maximum Members:   ${MEMBERMAX}
    Password:          ${PASSWRD}

Run this script again to stop the server."
    else
        {
        docker rm citra_server
        sudo docker run -d --name citra_server \
            --publish 24872:24872/udp \
            citraemu/citra-multiplayer-dedicated \
            --room-name "$ROOMNAME" \
            --room-description "$ROOMDESC" \
            --preferred-game "$PREFGAME" \
            --preferred-game-id ${PREFGAMEID} \
            --port ${PORT} \
            --max_members ${MEMBERMAX} \
            --token ${TOKEN} \
            --enable-citra-mods \
            --web-api-url https://api.citra-emu.org/
        } &> /dev/null
        echo "Server started! Here are the room stats.
======================================================
    Room Name:         ${ROOMNAME}
    Room Description:  ${ROOMDESC}
    Preferred Game:    ${PREFGAME}
    Preferred Game ID: ${PREFGAMEID}
    Port:              ${PORT}
    Maximum Members:   ${MEMBERMAX}
    Password:          None

Run this script again to stop the server."
    fi
fi
