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

os.environ['VCVARSALL'] = os.path.join(
    MSVC_PATH,
    'VC',
    'Auxiliary',
    'Build',
    'vcvarsall.bat',
)

HERE = os.path.dirname(__file__)

run = functools.partial(subprocess.run, stdout=subprocess.PIPE)

vcvars = run([
    os.path.join(HERE, 'vcvarsall_wrapper.bat'),
]).stdout.decode()

for line in vcvars.splitlines():
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

cl_exe_path = os.path.dirname(find('**', 'x64', 'cl.exe'))
os.environ['PATH'] += ';' + cl_exe_path

raise SystemExit(run([
    'pwsh.exe',
    os.path.join(HERE, 'build-anthem-msvc.ps1'),
]).returncode)
