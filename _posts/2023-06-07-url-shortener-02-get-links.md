---
layout: post
title: >
  Dev Journal #2: API get links
description:
# cover_image: 2023/url-shortener/01-arch-diagram.png
# image_folder: 2023/url-shortener
---

Let's add an endpoint to get links that we've created. Start with adding a `get` function to `packages/core/src/link.ts`:

```ts
export async function get(uid: string) {
  const result = await LinkEntity.get({ uid }).go();
  return result.data;
}
```

Add the `LinkGet` lambda function to the `API` stack in `stacks/API.ts` as well:

```ts
  const api = new Api(stack, "api", {
    routes: {
      "GET /link/{id}": {
        function: {
          functionName: `${stack.stackName}-LinkGet`,
          handler: "packages/functions/src/link/get.handler",
          bind: [table],
        },
      },
      // ...
    }
  }
```

You can view this code in the [**Add link get**][get-commit] commit.

[get-commit]: https://github.com/nickymarino/url-shortener/commit/e80548eb53241b31d7403277b6a5a2558cc9e3c0
