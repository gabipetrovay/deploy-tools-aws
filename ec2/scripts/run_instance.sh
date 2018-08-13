#!/usr/bin/env bash

set -e

TMPDIR=$(mktemp -d)

function display_help() {
  echo "Usage: $0"
}

function run_instance() {
  aws ec2 run-instances \
    --image-id "ami-c7e0c82c" \
    --count 1 \
    --instance-type "t2.micro" \
    --key-name "gabipetrovay@gmail.com" \
    --security-group-ids "sg-03f6c76cb27c2c4ce" \
    --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=ivansherbs.com},{Key=component,Value=webserver}]" > "${TMPDIR}/output.json"

  if [ $? != 0 ]; then
    exit 1
  fi

  local instance_id=$(node -e "console.log(require('${TMPDIR}/output.json').Instances[0].InstanceId)" 2> /dev/null)

  if [ $? != 0 ]; then
    exit 1
  fi

  echo "${instance_id}"
}

function get_instance_state() {
  local instance_id=$1

  aws ec2 describe-instances \
    --instance-id "${instance_id}" > "${TMPDIR}/output.json"

  if [ $? != 0 ]; then
    exit 1
  fi

  local instance_state=$(node -e "console.log(require('${TMPDIR}/output.json').Reservations[0].Instances[0].State.Name)")
  if [ $? != 0 ]; then
    exit 1
  fi

  echo "${instance_state}"
}

function associate_ip() {
  local instance_id=$1
  local ip_address=$2

  aws ec2 associate-address \
    --instance-id "${instance_id}" \
    --public-ip "${ip_address}"
}

function main() {
  local instance_id=$(run_instance)
  # TODO dynamically get or create on unused Elastic IP
  local ip_address=3.120.49.205

  while [ "running" != "$(get_instance_state "${instance_id}")" ]; do
    echo "Waiting for EC2 instance to be in running state..."
    sleep 5
  done

  associate_ip "${instance_id}" "${ip_address}" > /dev/null

  echo "Created EC2 instance ${instance_id} with IP address ${ip_address}"
}

main $@
