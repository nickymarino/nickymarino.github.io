---
layout: post
title: >
  Shorty Diary #10: Enable non-dev deployments
description:
# cover_image: 2023/url-shortener/01-arch-diagram.png
image_folder: 2023/url-shortener
---

To sanity check my work so far, I tried deploying a new non-development [stage][sst-stage], but I hit a few errors:

```bash
npx sst deploy --stage test
```

Luckily, these errors were pretty small! I just need to JSON-ify the output values for a few lambdas I had missed:

```ts
// functions/link/get.ts
const result = await Link.get(uid!);
return {
  body: JSON.stringify({
    link: result,
  },
})
```

```ts
// functions/link/list.ts
const result = await Link.list();
return {
  body: JSON.stringify({
    links: result,
  },
})
```

For good measure, I also added `eslint-config-next` to `package.json` and upgraded SST to `2.11`. These changes fixed my build issues, and I was able to deploy a prod-ish version of my code to AWS!

You can view these changes in the [**Enable non-dev deployments**][pr-20] PR.

[sst-stage]: https://sst.dev/chapters/stages-in-serverless-framework.html
[pr-20]: https://github.com/nickymarino/shorty/pull/20/files
