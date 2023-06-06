---
layout: post
title: >
  Dev Journal #5: A UI to list links
description:
# cover_image: 2023/url-shortener/01-arch-diagram.png
image_folder: 2023/url-shortener
---

The next step is to create the first UI page to display the list of existing links. Even though I followed [SST's docs][sst-nextjs] for creating a NextJS project, linking NextJS, SST, and MUI together was fraught.

## Bring NextJS and MUI Online

To get it all in sync, I ended up cloning the [SST NextJS quickstart example][sst-ex] and copying over files until I was able to see Next's `Hello World` UI:

![NextJS hello world screen]({% include _functions/image_path.html name='next-js-hello-world.png' %}){: .center}

Then, I did the same with [MUI's NextJS (Typescript) example][mui-ex] until I could *that* `Hello World` UI:

![MUI hello world screen]({% include _functions/image_path.html name='mui-example-ui.png' %}){: .center}

You can view these changes in the [**Next UI works in dev**][pr-4] and [**Add MUI**][pr-8] PRs.

I'm eternally grateful to the devs that have written countless examples for the [MUI][mui-examples] and [SST][sst-examples] projects; without those examples, I don't think I would've been able to move forward on this project with these tools.

## Poll the API for Links

Finally, let's connect the UI to the API data! First, we'll expose the `api` construct in `stacks/API.ts` so that we can [bind][sst-bind] it to the UI:

```ts
  // ...
  stack.addOutputs({
    ApiEndpoint: api.url,
  });

  return { api };
}
```

Then bind the `api` to the `site` under `stacks/Site.ts`:

```ts
export function Site({ stack }: StackContext) {
  const { api } = use(API);

  const site = new NextjsSite(stack, "site", {
    bind: [api],
  });
```

On the index page (`src/pages/index.tsx`), we can create a `Link` type and use `getServerSideProps` to fetch data from the API:

```ts
type Link = {
  shortPath: string;
  url: string;
  uid: string;
};

export const getServerSideProps: GetServerSideProps<{
  links: Link[];
}> = async (context) => {
  const endpoint = `${Api.api.url}/links`;
  const res = await fetch(endpoint);
  const data = await res.json();

  return { props: data.body };
};
```

There's a possible breakdown between the UI and API here if the `Link` type skews from what the API returns, so I created an [issue][zod-issue] to revisit this in the future. In that same file, we'll add some basic `p` tags for each link we receive:

```ts
export default function Home({ links }: { links: Link[] }) {
  return (
    <Container maxWidth="lg">
      {/* ... */}
        {links &&
          links.map((link) => (
            <Typography
              variant="body1"
              component="p"
              gutterBottom
              key={link.uid}
            >
              {link.shortPath} - {link.url}
            </Typography>
          ))}
```

One last thing: NextJS requires an experimental flag in `next.config.js` to make this work. I think it's to allow `async` calls inside `getServerProps`:

```js
const nextConfig = {
  reactStrictMode: true,
  webpack(config) {
    config.experiments = { ...config.experiments, topLevelAwait: true };
    return config;
  },
};
```

And there we go, links! You can view this code on the [**Index shows list of links**][pr-9] PR.

![NextJS hello world screen]({% include _functions/image_path.html name='mui-example-ui-with-links.png' %}){: .center}

[sst-nextjs]: https://docs.sst.dev/start/nextjs
[sst-ex]: https://github.com/serverless-stack/sst/tree/master/examples/quickstart-nextjs
[mui-ex]: https://github.com/mui/material-ui/tree/master/examples/material-next-ts
[pr-4]: https://github.com/nickymarino/url-shortener/pull/4
[pr-8]: https://github.com/nickymarino/url-shortener/pull/8
[mui-examples]: https://github.com/mui/material-ui/tree/master/examples
[sst-examples]: https://github.com/serverless-stack/sst/tree/master/examples
[sst-bind]: https://docs.sst.dev/resource-binding
[zod-issue]: https://github.com/nickymarino/url-shortener/issues/2
[pr-9]: https://github.com/nickymarino/url-shortener/pull/9
