#!/bin/bash
# clName=eks-sample
# eksctl create cluster --name $clName --version 1.18 --region ap-northeast-1 --fargate
eksctl create cluster -f cluster-eks-sample.yaml
