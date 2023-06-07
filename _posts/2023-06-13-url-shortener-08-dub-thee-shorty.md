---
layout: post
title: >
  Dev Journal #8: I dub thee shorty
description:
# cover_image: 2023/url-shortener/01-arch-diagram.png
image_folder: 2023/url-shortener
---

So far, I've been referring to this project as just `URL Shortener`, which doesn't do it justice. If I'm creating the Next Web Scale Startup™, I need a cool and flashy name for this project.

I spent a few hours poking at possible domain names in [AWS Route 53][r53], but it was tough to use. Every search would take a few seconds, none of my ideas were able to be purchased, and Route 53 even started recommending me domains that I had *already searched for* that were previously listed as unavailable.

I realized that since my plan is to host on `link.nickymarino.com` eventually, I don't need a custom domain. I can just use Route 53 as the [DNS service for the subdomain][dns] and [import the custom domain in SST][sst-custom] without worrying about migrating the parent domain `nickymarino.com` away from Hover[^1].

[^1]: [Hover][hover] is fantastic, by the way! I've used them for years and years now, and I've had a great experience.

So! Unconstrained by the fickle beast of whatever domains are up for grabs and don't cost $300/month, [without further ado][game-changer], we'll be doing business here as `shorty`.

Updating the code with the new name is pretty trivial. We'll change the name formally in `package.json`:

```jsonc
{
  "name": "shorty",
  // ...
```

As well as in `sst.config.ts`:

```ts
export default {
  config(_input) {
    return {
      name: "shorty",
      region: "us-east-1",
    };
  },
  stacks(app) {
    app.stack(Database);
    app.stack(API);
    app.stack(Site);
  },
} satisfies SSTConfig;
```

And then we'll need to update each of the sub-module `package.json` files, such as in `packages/core/package.json`:

```jsonc
{
  "name": "@shorty/core",
  // ...
```

Each import statement needs to be updated too, such as in `packages/functions/src/redirect.ts`:

```ts
import { Link } from "@shorty/core/link";

// ...
```

This was super straightforward using VSCode's [project-wide find and replace][replace]. However, because the name of the app changed, SST deploys my stack as `test-shorty` (in `STAGE-APPNAME` format) instead of `test-cow-link`[^2]. To sanity check, let's re-populate the DB with some links and load the UI to make sure it's all connected:

[^2]: And I had to manually delete each of the stacks for the old deploy. Grumble grumble.

![UI showing a list of links]({% include _functions/image_path.html name='08-link-list.png' %}){: .center}

And it works! You can view the code on the [**Rename project to shorty**][pr-13] PR.

[r53]: https://aws.amazon.com/route53/
[sst-custom]: https://docs.sst.dev/custom-domains
[dns]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/creating-migrating.html
[hover]: https://www.hover.com/
[game-changer]: https://www.youtube.com/watch?v=Rayuw_gSJ-s
[replace]: https://www.roboleary.net/vscode/2022/12/28/global-find-and-replace-all-text-in-vscode.html#:~:text=Alternatively%2C%20you%20can%20press%20Ctrl,Hurrah!
[pr-13]: https://github.com/nickymarino/url-shortener/pull/13
