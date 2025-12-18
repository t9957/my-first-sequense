#!/usr/bin/env bash

_is_installed() {
    local pac="$1"
    dpkg -l "$pac" 2>/dev/null | grep -q "^ii"
}

_want_to_write() {
  if [[ $# != 2 ]];then
    echo "argument_err ==> ${file}"
    return 2
  fi
  local str
  local file
  local perl_output
  str=$1
  file=$2
  perl_output=$(perl -0777 -ne "
    if (index(\$_, q{$(echo -e "${str}")}) != -1) { print 1 } else { print 0 }
  " "$file")
  if [[ "$perl_output" == "1" ]]; then
    echo "already_exists ==> ${file}"
    return 1
  else
    echo -e "\n${str}" >> "$file"
    echo "written ==> ${file}"
    return 0
  fi
}

_action_request_output(){
  local msg
  echo "==== please take action ========================"
  for msg in "$@";do
    echo "==> ${msg}"
  done
  echo "==== end ======================================="
}

main(){
  echo "starting first_sequence."
  local str
  if _is_installed "git"; then
    echo "unnecessary pac: git"
  else
    echo "reservation pac: git"
    sudo apt-get update | tee -a "./apt-install.log" > /dev/null 2>&1
    if sudo apt-get -y install git | tee -a "./apt-install.log" > /dev/null 2>&1; then
      echo "success install pac: git"
    else
      echo "failure install pac: git"
    fi
  fi
  [ ! -f ~/.ssh/github_sh_generate ] &&  ssh-keygen -t "ed25519" -N "" -f ~/.ssh/github_sh_generate -q
  str="Host github github.com\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/github_sh_generate"
  [ ! -f ~/.ssh/config ] && touch ~/.ssh/config
  _want_to_write "$str" ~/.ssh/config
  _action_request_output "To github" "$(cat ~/.ssh/github_sh_generate.pub)"
  echo "ending first_sequence."
}

main "$@"
