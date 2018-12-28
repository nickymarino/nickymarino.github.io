---
layout: post
title: Compiling Cub for Shortcuts
external_link: https://willhbr.net/2018/12/26/compiling-for-shortcuts/

# Use a date here to force this to come before today's other post
date: 2018-12-27 21:00:00
---

Earlier this week I heard about [Shortcuts JS](https://shortcuts.fun), which uses JavaScript to generate Shortcuts. Here's an example from their homepage:

```js
// We'll use this later to reference the output of a calculation
let calcVar = actionOutput();

// Define a list of actions
const actions = [
  comment({
    text: 'Hello, world!',
  }),
  number({
    number: 42,
  }),
  calculate({
    operand: 3,
    operation: '/',
  }, calcVar),
  showResult({
    // Use the Magic Variable
    text: withVariables`Total is ${calcVar}!`,
  }),
];
```

While this is a good first step to writing "real code" to make Shortcuts, specifying the operands and others in this fashion is clunky. I wondered how easy it would be to use the syntax tree instead to create the Shortcut, and Will Richardson has done that exact thing for [Cub](https://github.com/louisdh/cub) in a [blog post](https://willhbr.net/2018/12/26/compiling-for-shortcuts/):

>All I have to do was traverse the syntax tree and generate a Shortcuts file. In terms of code this is fairly straightforward - just add an extension to each AST node that generates the corresponding code.

I'm not familiar enough with iOS app development or Swift to do it myself, but it would be really interesting to write an app that can use something like [swift-ast](https://github.com/yanagiba/swift-ast) to generate Shortcuts. Who knows what power iOS users could get if they could program advanced Shortcuts using Swift?
