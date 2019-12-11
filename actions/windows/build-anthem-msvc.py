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
    k = m.group(1)
    v = m.group(2)
    os.environ[k] = v

run([
    'pwsh.exe',
    os.path.join(HERE, 'build-anthem-msvc.ps1'),
])
