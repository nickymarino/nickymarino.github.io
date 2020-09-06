---
layout: post
title: "AWS CLI: Multiple Named Profiles"
description: How to add multiple named profiles to kubernetes kubeconfig and AWS CLI
---

The AWS CLI supports named profiles so that you can quickly switch between different AWS instances, accounts, and credential sets. Let's assume you have two AWS accounts, each with an access key id and a secret access key. The first account is your default profile, and the second account is used less often.

## Adding a Named Profile

First, open `~/.aws/credentials` (on Linux & Mac) or `%USERPROFILE%\.aws\credentials` (on Windows) and add your credentials:

```
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE1
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY1

[user2]
aws_access_key_id=AKIAI44QH8DHBEXAMPLE2
aws_secret_access_key=je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY2
```

If your two profiles use different regions, or output formats, you can specify them in `~/.aws/config` (on Linux & Mac) or `%USERPROFILE%\.aws\config` (on Windows):

```
[default]
region=us-west-2
output=json

[profile user2]
region=us-east-1
output=text
```

Note: do **not** add `profile` in front of the profile names in the `credentials` file, like we do above in the `config` file.

Most AWS CLI commands support the named profile option `--profile`. For example, verify that both of your accounts are set up properly with `sts get-caller-identify`:

```
# Verify your default identity
$ aws sts get-caller-identity

# Verify your second identity
$ aws sts get-caller-identity --profile user2
```

EKS and EC2 commands also support the `--profile` option. For example, let's list our EC2 instances for the `user2` account:

```
$ aws ec2 describe-instances --profile user2
```

## Setting a Profile for Kubeconfig

The AWS CLI `--profile` option can be used to add new clusters to your `~/.kubeconfig`. By adding named profiles, you can switch between Kubernetes contexts without needing to export new AWS environment variables.

If your EKS instance is authenticated with only your AWS access key id and access key secret, add your cluster with `eks update-kubeconfig`:

```
$ aws eks update-kubeconfig --name EKS_CLUSTER_NAME --profile PROFILE
```

If your EKS instance uses an IAM Role ARN for authentication, first copy the role ARN from the AWS Console: Go to the EKS service page, then Clusters, then select your cluster name, and find the IAM Role ARN at the bottom of the page. The format of the role ARN is typically `arn:aws:iam::XXXXXXXXXXXX:role/role_name`. Then, use `eks update-kubeconfig`:

```
aws eks update-kubeconfig --name EKS_CLUSTER_NAME --role-arn ROLE_ARN --profile PROFILE
```

To verify that your `kubeconfig` is set properly, use [kubectx](https://github.com/ahmetb/kubectx) to switch to one of your new clusters and try to list out its services:

```
$ kubectx EKS_CLUSTER_NAME
Switched to context "EKS_CLUSTER_NAME".

$ kubectl get services
...
```
