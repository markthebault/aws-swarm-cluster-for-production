#!/bin/bash
OVPN_DATA=openvpn_data
BASEDIR=$(dirname "$0")

if [ -z $1 ] || [ -z $2 ]; then
  echo "USAGE $0 CONFIG_NAME FILE"
  exit 1
fi

ssh -F $BASEDIR/../ssh.cfg bastion docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn easyrsa build-client-full $1 nopass

ssh -F $BASEDIR/../ssh.cfg bastion docker run -v $OVPN_DATA:/etc/openvpn  --rm kylemanna/openvpn ovpn_getclient $1 > $2
