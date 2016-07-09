#!/usr/bin/python3.5

import json
import os

# TODO:
# opam switch
# opam list
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

settings = None

# Load settings and experiments context
with open("settings.json") as settings_file:
    settings = json.load(settings_file)
    print(settings)
   
# Experiments context
#experiments_context = {'source': {'git': {'branch': 'effect-handlers-compilation', 'url': 'https://github.com/links-lang/links.git'} } }

# Computes the hash of a given file
def compute_hash(file):
    BLOCKSIZE = 4096
    hasher = hashlib.md5()
    with open(file, 'rb') as afile:
        buf = afile.read(BLOCKSIZE)
        while len(buf) > 0:
            hasher.update(buf)
            buf = afile.read(BLOCKSIZE)
    return hasher.hexdigest()

# Expands environment variables
def expandvars(s):
    return os.path.expandvars(s)

def dump_command(cmd, ctxt):
    print("+ {:s}".format(cmd))

# Pipeline pattern
def run_pipeline(steps, seed):
    value = seed
    for step in steps:
        value = step(value)
    return value

def make_context(settings):
    mySettings = settings.copy()
    mySettings.update({'useCompilers': [0, 1, 2]})
    return mySettings

def make_experiment_config(settings):
    settings.update({'useCompilers': [0, 1, 2]})
    exps = []
    for (compId, val) in enumerate(settings['useCompilers']):
        compExps = []
        for exp in settings['experiments']:
            for prog in exp['programs']:
                if (any(comp['id'] == compId for comp in prog['compilers'])):
                    filename = expandvars(os.path.join(exp['directory'], prog['filename']))
                    compExps.append({'filename': filename, 'checksum': prog['checksum']})
        exps.append({'id': compId, 'programs': compExps})
    print(exps)
    exit(1)
    settings.update({'experiments': exps})
    return settings

def setup_links_experiments(settings):
    # git clone
    # git log
    # etc..
    return ()

def setup_environment():    
    return ()

def run_experiments(ctxt):
    return ctxt

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
    git = ctxt['settings']['source']['git']
    git_url = git['url']
    branch  = git['branch']
    cmd = "git clone -b {:s} {:s}".format(branch, git_url)
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
       
methodology = [
    make_experiment_config,
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

run_pipeline(methodology, settings)
