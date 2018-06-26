---
layout: post
title: Let's Use LaTeX!
---

[LaTeX](https://www.latex-project.org/) is a beautiful documentation system. It's similar to Markdown[^1], but has many more features and is commonly used for academic papers and other publications that require a lot of equations. In this quick how to, we cover how to install LaTeX and use Visual Studio Code as an editor/previewer.

# Installing LaTeX

I recommend downloading [TeX Live](https://www.tug.org/texlive/) for Windows/Linux, and [MacTex](https://www.tug.org/mactex/) for macOS.
# Setting up our editor

If you haven't already, install [Visual Studio Code](https://code.visualstudio.com/) and go through a [tutorial](https://code.visualstudio.com/docs/introvideos/basics). Then, we need to install our extension for LaTeX itself. Head over to [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) and click install. 

# Using LaTeX

Now that we have our editor setup, we can write our first project. All LaTeX documents have a (non-blank) file that ends with `.tex`, which is the "main" file that has all of the text of the document. Since LaTeX usually generates more files (such as .log, etc.) while building the document, it's recommended that every document you want to write has its own folder.

For starters, create a file named `example.tex`:

```
\documentclass{article}
    % General document formatting
    \usepackage[margin=0.7in]{geometry}
    \usepackage[parfill]{parskip}
    \usepackage[utf8]{inputenc}

\begin{document}
% Put your text here
This is starter text.
\end{document}
```

Press `Ctrl-Alt-B` to build your project (or use the Command Palette), then `Ctrl-Alt-T` to view the pdf in a new tab. The end result should look like this:

![picture](https://thepracticaldev.s3.amazonaws.com/i/h7udmn31hzf8cdc3zcwb.PNG)

# Conclusion

LaTeX and VSCode are a great combination that you can use to write beautiful reports and papers. Check out a [tutorial](https://www.latex-tutorial.com/tutorials/) or [two](http://www.rpi.edu/dept/arc/training/latex/class-slides-pc.pdf) to realize the full experience LaTeX has to offer.

*Edit: [Fanny](https://dev.to/fannyvieira) recommends another [great tutorial](https://github.com/LewisVo/Begin-Latex-in-minutes) as well.*

*Edit 2: Fixed a tutorial link.*

[^1]: Well, this depends on your definition of "similar", but I feel it is.