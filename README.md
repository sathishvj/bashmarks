### Bashmarks is a shell script that allows you to save and jump to commonly used directories. Now supports tab completion.

## Install

1. git clone git://github.com/sathishvj/bashmarks.git
2. cd bashmarks
3. make install
4. source **~/.local/bin/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file

## Shell Commands

    sb <bookmark_name> - Saves the current directory as "bookmark_name"
    cb <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"
    pb <bookmark_name> - Prints the directory associated with "bookmark_name"
    db <bookmark_name> - Deletes the bookmark
    ob <bookmark_name> - Open in Finder (mac only)
    lb                 - Lists all available bookmarks

    Note: tab completion for subdirectories doesn't work properly on mac but seems to work well on ubuntu.
    
## Example Usage

    $ cd /var/www/
    $ s webfolder
    $ cd /usr/local/lib/
    $ sb locallib
    $ lb
    $ cb web<tab>
    $ cb webfolder

    Additional feature added:
    $ cb webfolder/logs/abcd
    This will take you to /var/www/logs/abcd

## Where Bashmarks are stored
    
All of your directory bookmarks are saved in a file called ".sdirs" in your HOME directory.
