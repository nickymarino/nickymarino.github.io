---
layout: post
title: How To Change a Git Repo's Authentication Protocol
---

## HTTPS to SSH Key

Often I need to change a git repository to use an SSH key instead of my username and password to authenticate with the remote server. In order to do so, type the following in the repository's folder on your machine:

```
$ git config remote.origin.url git@github.com:username/repository_name.git
```

(Make sure to include the `.git` at the end of the repository name.)

## SSH Key to HTTPS

In order to change it to do the reverse, type:

```
$ git config remote.origin.url https://github.com/username/repository
```
