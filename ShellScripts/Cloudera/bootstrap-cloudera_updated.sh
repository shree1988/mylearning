#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.
# Usage: bootstrap-cloudera-1.0.sh {clusterName} {managment_node} {cluster_nodes} {isHA} {sshUserName} [{sshPassword}]

LOG_FILE="/var/log/cloudera-azure-initialize.log"



# Put the command line parameters into named variables
# parse command line arguments
while [[ ${#} -gt 1 ]]; do
    ARG="${1}"
    case ${ARG} in
        -masterip)
            MASTERIP="${2}"
            shift # move to next argument
        ;;
        -workerip)
            WORKERIP="${2}"
            shift # move to next argument
        ;;
        -admin)
            ADMINUSER="${2}"
            shift # move to next argument
        ;;
        -ha)
            HA="${2}"
            shift # move to next argument
        ;;
        -pass)
            PASSWORD="${2}"
            shift # move to next argument
        ;;
        -cmuser)
            CMUSER="${2}"
            shift # move to next argument
        ;;
        -cmpass)
            CMPASSWORD="${2}"
            shift # move to next argument
        ;;
        -email)
            EMAILADDRESS="${2}"
            shift # move to next argument
        ;;
        -biz)
            BUSINESSPHONE="${2}"
            shift # move to next argument
        ;;
        -fname)
            FIRSTNAME="${2}"
            shift # move to next argument
        ;;
        -lname)
            LASTNAME="${2}"
            shift # move to next argument
        ;;
        -jobrole)
            JOBROLE="${2}"
            shift # move to next argument
        ;;
        -jobfn)
            JOBFUNCTION="${2}"
            shift # move to next argument
        ;;
        -comp)
            COMPANY="${2}"
            shift # move to next argument
        ;;
        -install)
            INSTALLCDH="${2}"
            shift # move to next argument
        ;;
        -vmsize)
            VMSIZE="${2}"
            shift # move to next argument
        ;;
        -clustername)
            CLUSTERNAME="${2}"
            shift # move to next argument
        ;;
        -help)
            echo "${APP_FULL_NAME}: Application parameters are"
            echo "-fname first-name -- first name"
            echo "-lname last-name -- last name"
            echo "-install [y/n] -- install CDH"
            shift
            exit 1
        ;;
        *)
            # default action is to ignore the argument and move to the next argument
        ;;
    esac
    shift # move to next argument
done



# logs everything to the $LOG_FILE
log() {
  echo "$(date) $0: $*" >> "${LOG_FILE}"
}

log "------- bootstrap-cloudera.sh starting -------"

log "my vmsize: $VMSIZE"
log "master ip: $MASTERIP"

mip=${MASTERIP}

log "set private key"
#use the key from the key vault as the SSH private key
#openssl rsa -in /var/lib/waagent/*.prv -out /home/"${ADMINUSER}"/.ssh/id_rsa
prvfile=$(ls -ltr /var/lib/waagent/*.prv|tail -n 1|awk -F" " '{print $9}')
openssl rsa -in $prvfile -out /home/"${ADMINUSER}"/.ssh/id_rsa
chmod 600 /home/"$ADMINUSER"/.ssh/id_rsa
chown "$ADMINUSER" /home/"$ADMINUSER"/.ssh/id_rsa

file="/home/$ADMINUSER/.ssh/id_rsa"
key="/tmp/id_rsa.pem"
openssl rsa -in "$file" -outform PEM > $key

worker_ip=$MASTERIP,$WORKERIP
log "Worker ip to be supplied to next script: $worker_ip"
log "BEGIN: Starting detached script to finalize initialization"
if [ "$INSTALLCDH" == "True" ]
then
  if ! sh initialize-cloudera-server.sh "$CLUSTERNAME" "$key" "$mip" "$worker_ip" "$HA" "$ADMINUSER" "$PASSWORD" "$CMUSER" "$CMPASSWORD" "$EMAILADDRESS" "$BUSINESSPHONE" "$FIRSTNAME" "$LASTNAME" "$JOBROLE" "$JOBFUNCTION" "$COMPANY" "$VMSIZE">/dev/null 2>&1
  then
    log "initialize-cloudera-server.sh returned non-zero exit code"
    log "------- bootstrap-cloudera.sh failed -------"
    exit 1
  fi
  log "initialize-cloudera-server.sh returned exit code 0"
fi
log "END: Detached script to finalize initialization running. PID: $!"

log "------- bootstrap-cloudera.sh succeeded -------"

# always `exit 0` on success
exit 0