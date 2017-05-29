#!/bin/bash
OVPN_DATA=openvpn_data
BASEDIR=$(dirname "$0")

ssh -F $BASEDIR/../ssh.cfg bastion docker run -v $OVPN_DATA:/etc/openvpn  --rm kylemanna/openvpn ovpn_getclient CLIENTADMIN
