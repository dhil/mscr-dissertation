#!/usr/bin/python3.5

import json
import os
import subprocess
import shlex

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
#    print(settings)
   
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

def read_contents(files):
    contents = []
    for file in files:
        with open(file, 'r') as f:
            contents.append(f.readlines())
    return contents

def run(cmd, stdout= "/dev/stdout", stderr = "/dev/stderr"):
    command = shlex.split(cmd)
    exit_code = -1
    with open(stdout, 'w') as out:
        out.write("## [STDOUT] {:s}\n".format(cmd))
        out.flush()
        with open(stderr, 'w') as err:
            err.write("## [STDERR] {:s}\n".format(cmd))
            err.flush()
            proc = subprocess.Popen(command, stdout=out, stderr=err, shell=True)
            proc.wait(None)
            exit_code = proc.returncode
    return (exit_code, read_contents([stdout, stderr]))

def merge_logs(logfiles, rawlog):
    with open(rawlog, 'a+') as raw:
        for logfile in logfiles:
            with open(logfile, 'r') as log:
                raw.write(log.read())
        raw.flush()


def quiet_rm(filename):
    try:
        os.remove(filename)
    except OSError as e: # this would be "except OSError, e:" before Python 2.6
        if e.errno != errno.ENOENT: # errno.ENOENT = no such file or directory
            raise # re-raise exception if a different error occured

def join_paths(d1, d2):
    return expandvars(os.path.join(d1, d2))
        
# Log command
def run_and_log(entryname, cmd, ctxt):
    print("[{:s}] {:s}".format(entryname, cmd))
    logs    = ctxt['logs']
    rawlog  = expandvars(logs['rawlog'])
    logname = join_paths(ctxt['wd'], entryname)
    log_stdout = "{:s}.stdout.log".format(logname)
    log_stderr = "{:s}.stderr.log".format(logname)
    exit_code, [stdout, stderr] = run(cmd, stdout = log_stdout, stderr=log_stderr)
    logs['log'].append({'entry': entryname, 'exitCode': exit_code, 'stdout': stdout, 'stderr': stderr})

    merge_logs([log_stdout, log_stderr], rawlog)
    
    quiet_rm(log_stdout)
    quiet_rm(log_stderr)
    
    return exit_code
   

# Pipeline pattern
def run_pipeline(steps, seed):
    value = seed
    for step in steps:
        value = step(value)
    return value


## Checkout and build Links
# def git_clone_project(ctxt):
#     git = ctxt['settings']['project']['git']
#     git_url = git['url']
#     branch  = git['branch']
#     cmd = "git clone -b {:s} {:s}".format(branch, git_url)
#     dump_command("clone", cmd, ctxt)
#     return ctxt

def git_pull(ctxt):
    git = ctxt['settings']['project']['git']
    branch  = git['branch']
    cmd = "\"git pull origin {:s}\"".format(branch)
    run_and_log("pull", cmd, ctxt)
    return ctxt

def dump_most_recent_git_commit(ctxt):
    cmd = "\"git log -n1\""
    run_and_log("commitId", cmd, ctxt)
    return ctxt

def dump_opam(ctxt):
    cmd = "\"opam list\""
    run_and_log("packages", cmd, ctxt)
    cmd = "\"opam switch\""
    run_and_log("switch", cmd, ctxt)
    return ctxt

def dump_date(ctxt):
    cmd = "date +'%Y-%m-%d %H:%M:%S %Z%z [%A, %B]'"
    run_and_log("date", cmd, ctxt)
    return ctxt

def build_project(ctxt):
    cmd = "make nc"
    run_and_log("build", cmd, ctxt)
    return ctxt

def setup_links(settings):
    rawlog = join_paths("/tmp/exps", "setup.log")
    ctxt = {'wd': '/tmp/exps', 'settings': settings, 'logs': { 'rawlog': rawlog, 'log': [] } }

    cwd = os.getcwd()
    print(expandvars(settings['project']['directory']))
    os.chdir(expandvars(settings['project']['directory']))

    build_links = [ dump_date,
                    git_pull,
                    dump_most_recent_git_commit,
                    dump_opam,
                    build_project ]                    
                    
    run_pipeline(build_links, ctxt)
    os.chdir(cwd)
    print(str(ctxt))
    return ctxt


setup_links(settings)

def make_context(settings):
    mySettings = settings.copy()
    mySettings.update({'useCompilers': [0, 1, 2]})
    return mySettings

def select_experiments(settings):
    settings.update({'useCompilers': [0, 1, 2]})
    exps = []
    for (compId, val) in enumerate(settings['useCompilers']):
        compExps = []
        for exp in settings['experiments']:
            for prog in exp['programs']:
                if (any(comp['id'] == compId for comp in prog['compilers'])):
                    filename = expandvars(os.path.join(exp['directory'], prog['filename']))
                    compExps.append({'filename': prog['filename'], 'source': filename, 'checksum': prog['checksum']})
        exps.append({'id': compId, 'programs': compExps})
    print(exps)
    exit(1)
    ctxt = {'settings': settings, 'experiments': exps}
    return ctxt

def prepare_experiment(ctxt):
    compilers = ctxt['settings']['compilers']
    exps      = ctxt['experiments']
    for exp in exps:
        compId = exp['id']
        compiler = compilers[compId]
        if compiler['interactive']:
            build = "true" # Noop
            run = "{:s} {:s} {:s}".format(expandvars(compiler['exec']), expandvars(compiler['defaultFlags']), exp['source'])
        else:
            target = exp['filename'] + ".out"
            build = "{:s} {:s} {:s} -o {:s}".format(expandvars(compiler['exec']), expandvars(compiler['defaultFlags']), exp['source'], )


def run_experiments(ctxt):
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
       
# methodology = [
#     make_experiment_config,
#     dump_date,
#     dump_printenv,
#     dump_hostname,
#     dump_uname,
#     dump_who,
#     git_clone_project,
#     dump_most_recent_git_commit,
#     build_project,
#     run_experiments
#  ]

# run_pipeline(methodology, settings)
