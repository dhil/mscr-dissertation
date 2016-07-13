#!/bin/bash

WD="/tmp/exps"
LOGFILENAME="experiments.log"
LINKS_SRC_DIR="$HOME/projects/links/compiler"
LINKS_EXPDIR="$LINKS_SRC_DIR/benchmarks"
LINKS="$LINKS_SRC_DIR/links"
CONFIG="$LINKS_SRC_DIR/measure.config"
TIME="$HOME/.local/bin/time --verbose"
REPETITIONS=5
export LINKS_LIB="$HOME/projects/links/compiler/lib"

function log()
{
    TXT="$1"
    LOGFILE="$2"
    echo "## $TXT" >> $LOGFILE 2>&1
    echo "## $TXT"
}

function dump_env()
{
    echo "## date +'%Y-%m-%d %H:%M:%S %Z%z [%A, %B]'" >> $LOGFILE 2>&1
    date +'%Y-%m-%d %H:%M:%S %Z%z [%A, %B]' >> $LOGFILE 2>&1
    run_and_log printenv $LOGFILE
    run_and_log "who -a" $LOGFILE
    run_and_log "cat /etc/hostname" $LOGFILE
    run_and_log "uname -a" $LOGFILE
}

function run_and_log()
{
    CMD="$1"
    log "$CMD" "$2"
    $CMD >> $LOGFILE 2>&1
}

id=`expr $(ls -1 "$WD" | wc --l) + 1`
WD="$WD/$id"
LOGFILE="$WD/$LOGFILENAME-compiler"
mkdir -p "$WD"

# Build source
dump_env
cwd=$(pwd)
cd "$LINKS_SRC_DIR"
run_and_log "git pull origin effect-handlers-compilation" $LOGFILE
run_and_log "make nc" $LOGFILE
cd "$cwd"

# Compiler
for f in $(ls -1 $LINKS_EXPDIR | grep --color=none ".links$"); do
    dump_env
    # Build
    file="$LINKS_EXPDIR/$f"
    target="$WD/$f.out"
    log "[Compiler] Compiling program $file" $LOGFILE
    linksc="$LINKS -c --native --verbose $file -o $target"
    log "build:$f" $LOGFILE
    run_and_log "$linksc" "$LOGFILE"
    log "exit:$?" $LOGFILE
    log "Running $target $REPETITIONS times" $LOGFILE
    for i in $(seq 1 $REPETITIONS); do
        dump_env
        log "i:$i:" $LOGFILE
        run_and_log "$TIME $target" $LOGFILE
        log "exit:$?" $LOGFILE
    done
done

LOGFILE="$WD/$LOGFILENAME-interpreter"

# Interpreter
for f in $(ls -1 $LINKS_EXPDIR | grep --color=none ".links$"); do
    dump_env
    file="$LINKS_EXPDIR/$f"
    linksi="$LINKS --config=$CONFIG $file"
    log "Running $file $REPETITIONS times" $LOGFILE
    for i in $(seq 1 $REPETITIONS); do
        dump_env
        log "i:$i:" $LOGFILE
        run_and_log "$TIME $linksi" $LOGFILE
        log "exit:$?" $LOGFILE
    done
done
