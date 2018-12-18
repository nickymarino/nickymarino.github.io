---
layout: post
title: Expand Tilde Paths in Bash and Python
---

Sometimes it's necessary to reference files in a script using `~`. For example, if you want to schedule a [cron job](https://en.wikipedia.org/wiki/Cron) to run a script in a folder and place the results in the same folder, it's helpful to use absolute referencing of the files in the script.

## Bash

Here's my first attempt to append to a file:

```
$ ./my_folder/run.sh >> "~/my_folder/output.txt"
-bash: ~/my_folder/output.txt: No such file or directory
```

The issue with the above line is that the `~` is not expanded to the home directory (such as `/home/username/`) because it is inside the quotes. To [fix](https://stackoverflow.com/questions/36623731/bash-script-echo-returns-error-no-such-file-or-directory) this, move the path outside of the quotes, but leave the filename in single quotes (to escape the `.` in the extension):

```
$ ./my_folder/run.sh >> ~/my_folder/'output.txt'
```

## Python

I encountered a similar issue in Python:

```
>>> with open('~/my_folder/output.txt', 'r') as f:
...   contents = f.read()
...
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
FileNotFoundError: [Errno 2] No such file or directory: '~/my_folder/output.txt'
```

This can be [fixed](https://stackoverflow.com/questions/2057045/pythons-os-makedirs-doesnt-understand-in-my-path) using [`os.path.expanduser(path)`](https://docs.python.org/3/library/os.path.html#os.path.expanduser):

```
>>> import os
>>> filename = os.path.expanduser('~/my_folder/output.txt')
>>> with open(filename, 'r') as f:
...   contents = f.read()
...
>>> print(contents)
10
```
