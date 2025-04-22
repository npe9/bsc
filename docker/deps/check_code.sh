#!/bin/bash

set -e

function check_whitespace() {
    local RESULT=0

    # Check for trailing whitespace in Haskell/Bluespec files
    if [ $(git ls-files | egrep '\.(lhs|hs|hsc|bs|bsv)$' | grep -v -f .github/workflows/allow_whitespace.pats | xargs grep -H -n -e '\s$' -l -- | wc -l) -ne 0 ]; then
        git ls-files | egrep '\.(lhs|hs|hsc|bs|bsv)$' | grep -v -f .github/workflows/allow_whitespace.pats | xargs grep -H -n -e '\s$' -- || true
        echo "Trailing whitespace found!"
        RESULT=1
    fi

    # Check for tabs
    if [ $(git ls-files | egrep '\.(lhs|hs|hsc|bs)$' | xargs grep -H -n -e $'\t' -l -- | wc -l) -ne 0 ]; then
        git ls-files | egrep '\.(lhs|hs|hsc|bs)$' | xargs grep -H -n -e $'\t' -- || true
        echo "Tabs found!"
        RESULT=1
    fi

    return $RESULT
}

function check_confdir() {
    python3 - << 'EOF'
import glob
import os
import re
import sys

conf_re = re.compile(r'^CONFDIR\s*=\s*(.*)$')
exit_code = 0

for makefile in glob.glob('**/Makefile', recursive=True):
    dir_path = os.path.dirname(makefile)
    rel_path = os.path.relpath('.', dir_path)
    expect = '$(realpath {})'.format(rel_path)
    for l in open(makefile):
       m = conf_re.match(l.strip())
       if m and m.group(1) != expect:
           exit_code = 1
           print('Error: {} has wrong CONFDIR'.format(makefile))
           print('Expected: CONFDIR = {}'.format(expect))
           print('Found: {}'.format(l.rstrip('\n')))
sys.exit(exit_code)
EOF
}

function check_symlinks() {
    python3 - << 'EOF'
import glob
import os
import re
import sys

config_paths = ['config', '../config', '../../config', '../../../config']
exit_code = 0

for makefile in glob.glob('**/Makefile', recursive=True):
    dir_path = os.path.dirname(makefile)
    if not any(os.path.exists(os.path.join(dir_path, c)) for c in config_paths):
        print('Error: {} is missing a symlink to config'.format(dir_path))
        exit_code = 1

sys.exit(exit_code)
EOF
}

# Run all checks
check_whitespace
check_confdir
check_symlinks 