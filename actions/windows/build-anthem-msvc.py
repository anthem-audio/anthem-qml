import glob
import os
import os.path
import subprocess

MSVC_PATH = os.path.join(
    'C:',
    'Program Files (x86)',
    'Microsoft Visual Studio',
    '2019',
    'Enterprise',
)

HERE = os.path.dirname(__file__)

def find(*whomst):
    things = glob.glob(os.path.join(MSVC_PATH, *whomst), recursive=True)
    try:
        return things[0]
    except IndexError:
        raise OSError("Is this not `windows-latest`?")

os.environ['VCVARSALL'] = find('**', 'vcvarsall.bat')

vcvars = subprocess.run([
    os.path.join(HERE, 'vcvarsall_wrapper.bat'),
]).stdout.decode()

for line in vcvars.splitlines():
    k, v = line.split('=', 1)
    os.environ[k] = v

subprocess.run([
    'powershell.exe',
    os.path.join(HERE, 'build-anthem-msvc.ps1'),
])
