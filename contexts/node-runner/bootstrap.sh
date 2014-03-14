#!/bin/sh
EOT_CH="␄"
# Allow close means actual EOF will be interpreted
# as an end-of-script. This will allow StdinOnce: true
# to be sufficient. May come in handy for certain katas.
ALLOW_CLOSE=false

RUNNER=${RUNNER:-javascript}
TIMEOUT=${TIMEOUT:-3}

export HOME=/home/noderunner
. ~/.nvm/nvm.sh || errout 'Error sourcing NVM in bootstrap'
nvm use v0.10.22 > /dev/null 2>&1

SCRIPT=''

# TODO exit with a codewars internal error code
errout () {
    { echo "$1" 1>&2; exit 1; }
}

doRunner () {
    if [ "$RUNNER" = "javascript" ]; then
        timeout $TIMEOUT node -e "$1"
    elif [ "$RUNNER" = "coffeescript" ]; then
        timeout $TIMEOUT coffee -e "$1"
    else
        errout 'Runner not specified... aborting'
    fi
}

KATA_OUT='ERROR: stdout not assigned'
while read INPUT; do
    if [ "$INPUT" = "$EOT_CH" ]
    then
        # Temporary hack to fix multi-line output
        KATA_OUT=`doRunner "${SCRIPT}"`
        echo -e "$KATA_OUT"
        KATA_OUT='ERROR: stdout not assigned'
        SCRIPT=''
    else
        SCRIPT="${SCRIPT}${INPUT}"
    fi
done

EMPTY=''
if [ "$ALLOW_CLOSE" = true ] && [ "$SCRIPT" != "$EMPTY" ]; then
    doRunner "$SCRIPT"
fi
