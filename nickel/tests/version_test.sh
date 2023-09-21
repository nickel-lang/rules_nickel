_nickel=$1
_version_pattern=$2

("${_nickel}" --version 2>&1 || true) | grep "${_version_pattern}"
