---
layout: post
title: >
  Dev Journal #3: API list links
description:
# cover_image: 2023/url-shortener/01-arch-diagram.png
# image_folder: 2023/url-shortener
---

Let's add an endpoint to get a list of all links that we've created. Start with adding a `list` function to `packages/core/src/link.ts`:

```ts
export async function list() {
  const result = await LinkEntity.query.byUid({}).go();
  return result.data;
}
```

Add the `LinkList` lambda function to the `API` stack in `stacks/API.ts` as well:

```ts
  const api = new Api(stack, "api", {
    routes: {
      "GET /links": {
        function: {
          functionName: nameFor("LinkList"),
          handler: "packages/functions/src/link/list.handler",
        },
      // ...
    }
  }
```

And there we go! You can view this code in the [**Add link list**][list-commit] commit.

[list-commit]: https://github.com/nickymarino/url-shortener/commit/e8a5faf2acf35a8528e425d447edf4ef7c118358
