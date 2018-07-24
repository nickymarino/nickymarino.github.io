---
layout: post
title: Pointing a Hover Domain to a Github Pages Repo
---

My blog is currently hosted using [GitHub Pages](https://pages.github.com/)--which is a great way to host your static site or blog for free--by linking it to my custom domain that I purchased through [Hover](https://www.hover.com/). This post will explain the steps needed to point a GitHub Pages repo to a custom domain on Hover. 

## Link the Repo to the Domain

First you need to update your repository with your custom domain. In the settings for the repo, enter the domain in the "Custom domain" in the GitHub Pages section. 

![GitHub Pages settings for the repo]({{ "/assets/hover-github-pages_settings.png" | absolute_url }})

## A Records on Hover

Find [GitHub's current list of IP addresses](Then, go to your [Hover](https://www.hover.com/) account, select your domain, and go to the DNS tab) to add to the DNS tab on Hover. At the time of writing, these are:

```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

Then, go to your [Hover](https://www.hover.com/) account, select your domain, and go to the DNS tab. Delete any DNS records that have an "A" under "Records".

For each IP address on GitHub's help pages, add a DNS record. For each, the "Type" will be `A`, the "Hostname" will be `@`, and the "TTL" can be left as the default value.

![Hover DNS settings]({{ "/assets/hover-github-pages_hover.png" | absolute_url }})

## HTTPS needs refresh of url?? Wait several hours?