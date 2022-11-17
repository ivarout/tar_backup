#!/bin/bash
#title           : tar_backup.sh
#description     : A simple bash script for incremental tar backup automation
#author		     : Ingvar Out
#date            : 20221117
#version         : 0.1
#usage		     : ./tar_backup.sh [-r] [-f <tar file>] <target directory>
#bash_version    : 5.2.2(1)-release
#license         : GNU General Public License V3+

############################################################
# Help                                                     #
############################################################

Usage()
{
    echo "Syntax: $0 [-r] [-f <tar file>] <target directory>"
    echo "options:"
    echo "r     Restore data up to the most recent incremental backup in current directory, or, up to and including <filename>.tar if -f is specified"
    echo "f     Incremental backup file up to which to restore data from (only relevant if -r is specified)."
    echo
}

Help()
{
    # Display Help
    echo "Script for creating/restoring incremental backups using tar (and gzip). By default, an incremental backup will be created in the current folder, where tar filenames will be appended by current date and time. If the -r (recover) option is specified, instead, the data from the incremental backup will be restored."
    echo
    echo "Run script in the directory containing the backup .tar files."
    Usage
}

############################################################
# Process Input                                            #
############################################################

# Get the options
while getopts ":hrf:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      r) # Restore from backup
         RESTORE=true;;
      f) # Enter filename
         if [ ! -v RESTORE ]; then
            echo "Error: -f option requires -r option to be set"
            Usage
            exit
         fi
         TARINCREMENT=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         Usage
         exit;;
   esac
done

if [ -v RESTORE ]; then
    echo "Restoring from backup"
    shift
fi

if [ -v TARINCREMENT ]; then
    if [ ! -f $TARINCREMENT ]; then
        echo "$TARINCREMENT does not exist"
        exit
    fi
    echo "Up to and including $TARINCREMENT"
    shift; shift
fi

if [ $# -ne 1 ]; then
    echo "Error: Please provide one backup directory"
    Usage
    exit
fi
DATADIR=$1

############################################################
# Restore From Incremental Backup                          #
############################################################

if [ -v RESTORE ]; then

    if [ -d $DATADIR ]; then
        echo "Are you sure you want to recover the '$DATADIR' directory? Non-backed up data may be lost"
        echo "(yes/No):"
        read varname
        if [ "$varname" != "yes" ]; then
            echo "data recovery cancelled."
            exit
        fi
    fi

    TARFILES=`ls *.tar.gz`
    for FILE in $TARFILES
    do
        echo "Recovering $FILE"
        echo "======================================================="
        tar --extract --verbose --verbose --listed-incremental=/dev/null --file=$FILE $DATADIR
        if [ "$TARINCREMENT" ==  "$FILE" ]; then
            break;
        fi
        echo
    done
    exit
fi

############################################################
# Create Incremental Backup                                #
############################################################

if [ ! -d $DATADIR ]; then
    echo "Error: Directory $DATADIR does not exist"
    exit
fi

BASENAME=$(basename -- $DATADIR)
DATETIME=$(date +'%_Y_%m_%d_%H_%M_%S')
TAR=${BASENAME}.${DATETIME}.tar.gz
SNAR=${BASENAME}.snar

tar --create --gzip --verbose --verbose --listed-incremental=${SNAR} --file=${TAR} $1
