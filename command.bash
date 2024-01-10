#!/bin/bash

# Define the version
VERSION="v0.1.0"

# Function to display the manual page
show_manual() {
    # ... (previous manual content)
    echo "Part1 | Level Easy"
    echo "  internsctl cpu getinfo        Get CPU information (similar to lscpu)"
    echo "  internsctl memory getinfo     Get memory information (similar to free)"
    echo "Part2 | Level Intermediate"
    echo "  internsctl user create <username>          Create a new user"
    echo "  internsctl user list                       List all regular users"
    echo "  internsctl user list --sudo-only           List users with sudo permissions"
    echo "Part3 | Advanced Level"
    echo "  internsctl file getinfo <file-name>        Get file information"
    echo "      Options:"
    echo "        --size, -s           Print file size"
    echo "        --permissions, -p   Print file permissions"
    echo "        --owner, -o         Print file owner"
    echo "        --last-modified, -m Print last modified time"
}

# Function to handle CPU information
get_cpu_info() {
    lscpu
}

# Function to handle memory information
get_memory_info() {
    free
}

# Function to create a new user
create_user() {
    if [ -z "$1" ]; then
        echo "Error: Username not provided. Usage: internsctl user create <username>"
        exit 1
    fi

    sudo useradd -m "$1"
    echo "User $1 created successfully."
}

# Function to list users
list_users() {
    if [ "$1" == "--sudo-only" ]; then
        getent group sudo | cut -d: -f4 | tr ',' '\n'
    else
        cut -d: -f1 /etc/passwd
    fi
}

# Function to get file information
get_file_info() {
    if [ -z "$1" ]; then
        echo "Error: File name not provided. Usage: internsctl file getinfo [options] <file-name>"
        exit 1
    fi

    file_name="$1"
    shift

    file_info="File: $file_name"

    while [ $# -gt 0 ]; do
        case "$1" in
            --size|-s)
                file_info="$file_info\nSize(B): $(stat -c%s $file_name)"
                ;;
            --permissions|-p)
                file_info="$file_info\nAccess: $(stat -c%a $file_name)"
                ;;
            --owner|-o)
                file_info="$file_info\nOwner: $(stat -c%U $file_name)"
                ;;
            --last-modified|-m)
                file_info="$file_info\nModify: $(stat -c%y $file_name)"
                ;;
            *)
                echo "Error: Unknown option. Use 'internsctl file getinfo --help' for usage information."
                exit 1
                ;;
        esac
        shift
    done

    echo -e "$file_info"
}

# Main script
case "$1" in
    cpu)
        get_cpu_info
        ;;
    memory)
        get_memory_info
        ;;
    user)
        case "$2" in
            create)
                create_user "$3"
                ;;
            list)
                list_users "$3"
                ;;
            *)
                echo "Error: Unknown subcommand. Use 'internsctl user --help' for usage information."
                exit 1
                ;;
        esac
        ;;
    file)
        if [ "$2" == "getinfo" ]; then
            shift 2
            get_file_info "$@"
        else
            echo "Error: Unknown subcommand. Use 'internsctl file --help' for usage information."
            exit 1
        fi
        ;;
    --help)
        show_help
        ;;
    --version)
        echo "internsctl $VERSION"
        ;;
    *)
        echo "Error: Unknown command. Use 'internsctl --help' for usage information."
        exit 1
        ;;
esac

exit 0
