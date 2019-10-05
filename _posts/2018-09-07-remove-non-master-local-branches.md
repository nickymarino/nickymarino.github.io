---
layout: post
title: Removing Local Git Branches That Aren't 'master'
---

Every so often, I'll want to delete all of my local branches for a repository that aren't the `master` branch. An easy command to do this is:

```
$ git branch | grep -v "master" | xargs git branch -d
```

(If you want to keep multiple branches, such as `master` and `develop`, you can chain them together using `grep -v "master\|develop"`)

`git branch` lists all of the local branches for the repo, `grep -v` prints all of the lines from the previous command that don't match "master", and `xargs` takes each line from the previous output and runs `git branch -d <output_line>`. 

I recommend using `-d` rather than `-D` in case git recommends not deleting the branch.
