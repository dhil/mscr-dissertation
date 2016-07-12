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
    #command = shlex.split(cmd)
    command = cmd
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
def save_json(data, filename):
    with open(filename, 'w') as f:
        f.write(json.dumps(data, indent=2, sort_keys=False))
    return ()


def log_raw(stream, ctxt):
    rawlog  = expandvars(ctxt['logs']['rawlog'])
    with open(rawlog, 'a+') as raw:
        for line in stream:
            raw.write(line)
        raw.flush()
    return ()

def log_entry(log, entry, log2):
    return ()
    
def run_and_log(entryname, cmd, ctxt):
    print("[{:s}] {:s}".format(entryname, cmd))
    logs    = ctxt['logs']
    logname = join_paths(ctxt['settings']['wd'], entryname)
    log_stdout = "{:s}.stdout.log".format(logname)
    log_stderr = "{:s}.stderr.log".format(logname)
    exit_code, [stdout, stderr] = run(cmd, stdout = log_stdout, stderr=log_stderr)
    logs['log'].append({'entry': entryname, 'exitCode': exit_code, 'stdout': stdout, 'stderr': stderr})
   
    log_raw(stdout, ctxt)
    log_raw(stderr, ctxt)
    
    quiet_rm(log_stdout)
    quiet_rm(log_stderr)
    
    return exit_code
   

# Pipeline pattern
def run_pipeline(steps, seed):
    value = seed
    for step in steps:
        value = step(value)
    return value


## Env info
def dump_date(ctxt):
    cmd = "date +'%Y-%m-%d %H:%M:%S %Z%z [%A, %B]'"
    run_and_log("date", cmd, ctxt)
    return ctxt

def dump_printenv(ctxt):
    cmd = "printenv"
    run_and_log("printenv", cmd, ctxt)
    return ctxt

def dump_hostname(ctxt):
    cmd = "cat /etc/hostname"
    run_and_log("hostname", cmd, ctxt)
    return ctxt

def dump_uname(ctxt):
    cmd = "uname -a"
    run_and_log("uname", cmd, ctxt)
    return ctxt

def dump_who(ctxt):
    cmd = "who -a"
    run_and_log("who", cmd, ctxt)
    return ctxt

dump_env = [ dump_date,
             dump_who,
             dump_hostname,
             dump_uname,
             dump_printenv ]

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
    cmd = "git pull origin {:s}".format(branch)
    run_and_log("pull", cmd, ctxt)
    return ctxt

def dump_most_recent_git_commit(ctxt):
    cmd = "git log -n1"
    run_and_log("commitId", cmd, ctxt)
    return ctxt

def dump_opam(ctxt):
    cmd = "opam list"
    run_and_log("packages", cmd, ctxt)
    cmd = "opam switch"
    run_and_log("switch", cmd, ctxt)
    return ctxt

def build_project(ctxt):
    cmd = "make nc"
    run_and_log("build", cmd, ctxt)
    return ctxt

def setup_links(settings):
    wd = settings['wd']
    rawlog = join_paths(wd, "setup.log")
    jsonlog = join_paths(wd, "setup.json")
    ctxt = {'settings': settings, 'logs': { 'rawlog': rawlog, 'log': [] } }

    cwd = os.getcwd()
    #print(expandvars(settings['project']['directory']))
    os.chdir(expandvars(settings['project']['directory']))

    build_links = [ dump_date,
                    git_pull,
                    dump_most_recent_git_commit,
                    dump_opam,
                    build_project ]                    
                    
    ctxt = run_pipeline(dump_env + build_links, ctxt)
    os.chdir(cwd)
    
    # Dump json log
    save_json(ctxt, jsonlog)
    
    return ctxt

def select_experiments(ctxt):
    settings = ctxt['settings']
    settings.update({'useCompilers': [0, 1, 2]})
    exps = []
    for (compId, val) in enumerate(settings['useCompilers']):
        compExps = []
        for exp in settings['experiments']:
            for prog in exp['programs']:
                if (any(comp['id'] == compId for comp in prog['compilers'])):
                    filename = expandvars(os.path.join(exp['directory'], prog['filename']))
                    compExps.append({'filename': prog['filename'], 'source': expandvars(filename), 'checksum': prog['checksum']})
        exps.append({'id': compId, 'programs': compExps})
    ctxt.update({'experiments': exps})
    return ctxt

def prepare_compiler_experiment(programs, compiler, settings):
    progs = []
    for prog in programs:
        name = "{:s}-{:s}".format(prog['filename'], compiler['name'])
        target = "{:s}.out".format(join_paths(settings['wd'], prog['filename']))
        build = "{:s} {:s} {:s} -o {:s}".format(expandvars(compiler['exec']), expandvars(compiler['defaultFlags']), prog['source'], target)
        run    = target
        progs.append({'name': name, 'build': build, 'run': run, 'interactive': False, 'checksum': prog['checksum']})
    return progs

def prepare_interpreter_experiment(programs, interpreter, settings):
    progs = []
    for prog in programs:
        name = "{:s}-{:s}".format(prog['filename'], interpreter['name'])
        run = "{:s} {:s} {:s}".format(expandvars(interpreter['exec']), expandvars(interpreter['defaultFlags']), prog['source'])
        progs.append({'name': name, 'run': run, 'interactive': True, 'checksum': prog['checksum']})
    return progs

def prepare_builds(ctxt):
    compilers = ctxt['settings']['compilers']
    exps      = ctxt['experiments']
    progs = []
    for exp in exps:
        compId = exp['id']
        compiler = compilers[compId]
        if compiler['interactive']:
            progs = progs + prepare_interpreter_experiment(exp['programs'], compiler, ctxt['settings'])
        else:
            progs = progs + prepare_compiler_experiment(exp['programs'], compiler, ctxt['settings'])
    ctxt.update({'experiments': progs})
    return ctxt

def prepare_experiments(settings):
    prepare = [ select_experiments,
                prepare_builds ]
    rawlog = join_paths(settings['wd'], "prepare.log")
    jsonlog = join_paths(settings['wd'], "prepare.json")
    ctxt = {'settings': settings.copy(), 'logs': { 'rawlog': rawlog, 'log': [] } }
    ctxt = run_pipeline(dump_env + prepare, ctxt)
    # Dump JSON
    save_json(ctxt, jsonlog)
    return ctxt

## Running experiments
def run_experiment(ctxt):
    settings = ctxt['settings']
    exp = ctxt['experiment']    
    run_pipeline(dump_env, ctxt)
    # build
    run_and_log("build", exp['build'], ctxt)
    # Run X times
    prog = exp['run']
    n = settings['repetitions']
    return ctxt

def run_experiments(ctxt):
    settings = ctxt['settings']
    exps = ctxt['experiments']
    for exp in exps:
        expContext = {'settings': settings.copy(), 'experiment': exp}
        run_experiment(expContext)
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

wd = settings['wd']
for _, dirnames, _ in os.walk(wd):
    wd = join_paths(wd, str(len(dirnames)+1))
    os.makedirs(wd)
    break
settings.update({'wd': wd})

setup_links(settings.copy())
ctxt = prepare_experiments(settings.copy())
#run_experiments(ctxt)

