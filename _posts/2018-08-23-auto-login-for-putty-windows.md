---
layout: post
title: Auto Login for PuTTY (Windows)
---

Often I find myself wanting to have an easy way to SSH into a server on a Windows PC. Unfortunately, SSH keys on Windows can often be a challenge, but there's an easy way to have PuTTY connect without needing to type in a password every time.

To create a shortcut for a PuTTY connection to automatically log in, you only need two things: the name of the profile (in PuTTY) that has the connection and appearance settings, and the password to your account (for the server). Right click on the desktop to create a new shortcut, then for the link type:

```
"C:\Program Files (x86)\PuTTY\putty.exe" -load "<profileName>" -pw "<password>"
```

If you saved PuTTY to a different location other than `Program Files (x86)`, then you'll also need to change the location of `putty.exe` in the command above.

Once you've created the shortcut, you can pin it to the taskbar or the start menu for easy access!

_These instructions were inspired by the instructions for the Purdue ECE 264 [course page](https://engineering.purdue.edu/ece264/16au/setup)_.