#!/bin/bash

echo "Select Architecture:"
echo "1. 1-Tier"
echo "2. 2-Tier"
echo "3. 3-Tier"
read TIER

echo "Enter GitHub Repo URL:"
read REPO

echo "Select Preference:"
echo "1. Performance"
echo "2. Cost"
echo "3. Intelligence"
read PREF

echo "Select OS:"
echo "1. Ubuntu"
echo "2. Amazon Linux"
read OS

# Map values
case $TIER in
  1) TIER="1-tier";;
  2) TIER="2-tier";;
  3) TIER="3-tier";;
esac

case $PREF in
  1) PREF="performance";;
  2) PREF="cost";;
  3) PREF="intelligence";;
esac

case $OS in
  1) OS="ubuntu";;
  2) OS="amazon";;
esac

# Pass to Terraform
terraform apply \
  -var="tier=$TIER" \
  -var="repo_url=$REPO" \
  -var="preference=$PREF" \
  -var="os=$OS"