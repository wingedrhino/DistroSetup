#!/bin/bash

# Set ulimit values for nofile and nproc to 99999 for the current shell session
ulimit -Su 99999 # Set soft limit for number of user processes
ulimit -Hu 99999 # Set hard limit for number of user processes
ulimit -Sn 99999 # Set soft limit for number of open files
ulimit -Hn 99999 # Set hard limit for number of open files

echo "ulimit values set for the current session."

