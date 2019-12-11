import glob
import os.path

MSVC_PATH = os.path.join(
    'C:\\',
    'Program Files (x86)',
    'Microsoft Visual Studio',
    '2019',
    'Enterprise',
)

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

print(cl_exe_path, end='')
