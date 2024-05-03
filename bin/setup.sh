#!/bin/bash
set -e

service_name=LinebotOpenAI

pip3 install -r requirements.txt -t build/layers/$service_name/python
terraform init
