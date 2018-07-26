---
layout: post
title: Pointing a Github Pages Repo to a Hover Domain
---

My blog is currently hosted using [GitHub Pages](https://pages.github.com/)&mdash;which is a great way to host your static site or blog for free&mdash;by linking it to my custom domain that I purchased through [Hover](https://www.hover.com/). While both of these services are amazing, connecting the two required many open tabs and several waiting periods. This post will explain the steps needed to point a GitHub Pages repo to a custom domain on Hover. 

## Preflight Check

Before connecting GitHub Pages to a custom domain, I first updated my blog on my repository [nickymarino.github.io](https://github.com/nickymarino/nickymarino.github.io), and checked that it was displaying properly at its default website (normally https://nickymarino.github.io).

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

It may take several hours (or up to about a day) for the changes to take effect. Take a break, get some sleep, and then come back to your domain to make sure everything's working. Now we can enforce HTTPS!

## Create HTTPS certificate

If you head back to your repo's settings page to enfore HTTPS, you might see the following error:

**Insert picture**

Per [GitHub's troubleshooting page](https://help.github.com/articles/troubleshooting-custom-domains/#https-errors), you need to remove and then re-add your custom domain for your repository. Wait around 24 hours for the certificate to be generated, and you should be good to go!
