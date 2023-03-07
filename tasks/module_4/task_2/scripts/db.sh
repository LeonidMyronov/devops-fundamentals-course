#!/bin/bash

declare dbname=users.db
declare path=../data
declare fail_answer='Error. Something went wrong.'

function validate_user_input {
    user_input=$1
    until [[ $user_input =~ ^[[:alpha:]]+$ ]]; do
        echo "user $2 – Latin letters only."
        read -p "Enter user $2: " user_input
        
    done
}

function add {
    local user
    local role

    read -p "Enter user name: " user
    validate_user_input $user "name"
    user=$user_input

    read -p "Enter user role: " role
    validate_user_input $role "role"
    role=$user_input

    echo "$user, $role" >> $path/$dbname
    echo "New record added successfully."
}

function backup {
    cp -f $path/$dbname "$path/$(date +'%F')-$dbname.backup"
    if [ $? ]
        then echo 'Backup created successfully'
        else echo $fail_answer
    fi
}

function restore {
    backup=$(find $path/ -name *.backup |  grep -E '[0-9]{4}.*backup$' | tail -1)
    if [ -z $backup ]
        then echo "No backup file found."
        else cp $backup $path/$dbname
            if [ $? ]
                then echo 'DB restored successfully'
                else echo $fail_answer
            fi
    fi
}

function find {
    read -p "Type user name " search
    result=$(grep -E -i .*$search.*, $path/$dbname)

    if [[ -z $result ]]
        then echo "User not found."
        exit 0
    fi

    echo -e "\nENTRIES FOUND:\n"
    grep -E -i .*$search.*, $path/$dbname
    echo

}

function list {
    if [[ $1 == "--inverse" ]]
        then cat -n $path/$dbname | sed -E 's/([0-9]+)/\1./' | sort -r
        else cat -n $path/$dbname | sed -E 's/([0-9]+)/\1./'
    fi
}

function help {
    echo
    echo "SYNOPSIS: $0 [arg]"; echo
    echo "DESCRIPTION:"
    echo "This script supports the following commands:"; echo
    echo "add       Adds a new line to the users.db. Script must prompt user to type a username of new entity.
          After entering username, user must be prompted to type a role."
    echo "backup    Creates a new file, named %date%-$dbname.backup which is a copy of current $dbname."
    echo "restore   Takes the last created backup file and replaces users.db with it. 
          If there are no backups - script should print: “No backup file found”."
    echo "find      Prompts user to type a username, then prints username and role if such exists in $dbname. 
          If there is no user with selected username, script must print: “User not found”. 
          If there is more than one user with such username, print all found entries."
    echo "list      Prints contents of users.db in format: N. username, role where N – a line number of an actual record
          Accepts an additional optional parameter inverse which allows to get result in an opposite order – from bottom to top."
}

function create_db {
    local answer
    echo "Warning! DB does not exist."
    read -p "Would you like to create the DB file?(y/n) "  answer
    if [[ $answer =~ [yY] ]]
        then 
            touch "$path/$dbname" 
            echo 'DB created successfully.'
        else echo 'Exit script.'; exit 0
    fi
}

function validate_db_exists {
    if [ ! -f $path/$dbname ]
        then create_db; 
    fi
}


validate_db_exists

case $1 in
    add) add;;
    backup) backup;;
    restore) restore;;
    find) find;;
    list) list $2;;
    help | '') help;;
esac