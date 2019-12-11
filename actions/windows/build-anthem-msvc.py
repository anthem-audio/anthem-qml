import functools
import glob
import os
import os.path
import re
import subprocess

MSVC_PATH = os.path.join(
    'C:\\',
    'Program Files (x86)',
    'Microsoft Visual Studio',
    '2019',
    'Enterprise',
)

HERE = os.path.dirname(__file__)

def run(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in popen.stdout:
        yield line.decode()
    popen.stdout.close()
    return popen.wait()

vcvars = run([
    os.path.join(HERE, 'vcvarsall_wrapper.bat'),
])

for line in vcvars:
    pattern = r'''\"(.*)\",\"(.*)\"'''
    m = re.search(pattern, line)
    if not m:
        continue
    try:
        k = m.group(1)
        v = m.group(2)
        os.environ[k] = v
    except IndexError:
        continue

def find(*whomst):
    things = glob.glob(os.path.join(MSVC_PATH, *whomst), recursive=True)
    try:
        return things[0]
    except IndexError:
        raise OSError("Is this not `windows-latest`?")

cl_exe_path = os.path.dirname(find(
    'VC',
    'Tools',
    'MSVC',
    '*',
    'bin',
    'Hostx64',
    'x64',
    'cl.exe',
))

os.environ['PATH'] += ';' + cl_exe_path

raise SystemExit(run([
    'pwsh.exe',
    os.path.join(HERE, 'build-anthem-msvc.ps1'),
]))
