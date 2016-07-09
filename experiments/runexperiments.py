#!/usr/bin/python3.5

# TODO:
# Read config
# Setup environment
# Dump printenv
# cat /etc/hostname
# uname -a
# dump who
# Pull from git
# Get git commit id
# Run experiments
#   - Build - dump stdout and stderr (exit 0)
#   - Run X times; compute hash of each output; compare
# Notify about results (e.g. e-mail)

# Experiments context
experiments_context = {'continue': True, 'name': "World"}


def dump_command(cmd, ctxt):
    print("+ " + str(cmd))

# Pipeline pattern
def run_pipeline(steps, seed):
    value = seed
    for step in steps:
        value = step(value)
    return value


def dump_date(ctxt):
    cmd = "date +'%Y-%m-%d %H:%M:%S %Z%z [%A, %B]'"
    dump_command(cmd, ctxt)
    return ctxt

def dump_printenv(ctxt):
    cmd = "printenv"
    dump_command(cmd, ctxt)
    return ctxt

def dump_hostname(ctxt):
    cmd = "cat /etc/hostname"
    dump_command(cmd, ctxt)
    return ctxt

def dump_uname(ctxt):
    cmd = "uname -a"
    dump_command(cmd, ctxt)
    return ctxt

def dump_who(ctxt):
    cmd = "who -a"
    dump_command(cmd, ctxt)
    return ctxt

def git_clone_project(ctxt):
    cmd = "git clone -b effect-handlers-compilation https://github.com/links-lang/links.git"
    dump_command(cmd, ctxt)
    return ctxt

def dump_most_recent_git_commit(ctxt):
    cmd = "git log | head -n3"
    dump_command(cmd, ctxt)
    return ctxt

def build_project(ctxt):
    cmd = "make nc"
    dump_command(cmd, ctxt)
    return ctxt

def run_experiments(ctxt):
    return ctxt

def print_hello(ctxt):
    if ctxt['continue']:
        print("Hello " + str(ctxt['name']))
        ctxt.update({'name': "Foobar"})
        ctxt.update({'continue': False})
    return ctxt
        
methodology = [
    dump_date,
    dump_printenv,
    dump_hostname,
    dump_uname,
    dump_who,
    git_clone_project,
    dump_most_recent_git_commit,
    build_project,
    run_experiments
 ]

run_pipeline(methodology, experiments_context)
