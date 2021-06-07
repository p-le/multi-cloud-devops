#!/usr/bin/env bash
set -e
gcloud compute instance-groups managed wait-until $1 --stable --region $2

gcloud compute instance-groups managed list-instances $1 --region $2

