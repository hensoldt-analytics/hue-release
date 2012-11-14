#!/bin/bash

RUN_DIR=/home/sandbox/tutorials/tutorials_app/run
GIT_REPO=git@github.com:hortonworks/sandbox-shared.git

USER=root

if [[ "$1" == "--migrate" ]]; then
    echo "Migrating DB..."
    cd "$RUN_DIR/../db"
    rm -f lessons.db
    cd ../../
    ./.env/bin/python manage.py syncdb
    exit 0
fi


cd $RUN_DIR

[ -d git_files_all ] || mkdir git_files_all
chown $USER git_files_all
cd git_files_all
CUR_DIR="`pwd`"
[ ! -d .git ] && su $USER -c "cd $CUR_DIR && git init && git remote add origin $GIT_REPO"
echo -n "Pull...  "
su $USER -c "cd $CUR_DIR && git pull origin master" # >/dev/null 2>&1
echo "Done"
cd - >/dev/null
cd $RUN_DIR
[ ! -L git_files ] && ln -s git_files_all/tutorials/tutorials git_files

# updating tutorials version
if [[ -f 'git_files/version' ]]; then
cat git_files/version > /tmp/tutorials_version.info
fi

echo -n "Updating DB...  "
$RUN_DIR/../../.env/bin/python run.py &>/dev/null
echo "Done"
