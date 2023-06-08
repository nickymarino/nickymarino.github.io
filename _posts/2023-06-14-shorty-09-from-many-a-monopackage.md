---
layout: post
title: >
  Dev Journal #9: From Many, a Mono Package
description:
# cover_image: 2023/url-shortener/01-arch-diagram.png
image_folder: 2023/url-shortener
---

I hit a snag in my dev experience: for some reason, Visual Studio Code isn't able to understand my submodules under the `packages/` folder anymore, so any third party libraries in `packages/core` or `packages/functions` are unknown:

![VSCode complier error]({% include _functions/image_path.html name='09-vs-code-error-1.png' %}){: .center}

Also concerning: VSCode doesn't appear to understand the Typescript import in `tsconfig.json` files in `packages/`:

![VSCode complier error]({% include _functions/image_path.html name='09-vs-code-error-2.png' %}){: .center}

Research didn't turn up much; the solutions were [beyond][research-1] [me][research-2] at best. Searching the SST Discord didn't turn up anything either, so I decided to re-examine the [SST NextJS example][sst-next].

## The Setup Change

Previously, borrowing from the [SST DynamoDB REST API example][sst-dynamo], I had a `packages/` folder that included submodules for `core` and `links`:

```text
├── packages
│   ├── core
│   │   ├── src
│   │   │   ├── dynamo.ts
│   │   │   └── link.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── functions
│       ├── src
│       │   ├── link
│       │   │   ├── create.ts
│       │   │   ├── get.ts
│       │   │   ├── list.ts
│       │   │   └── patch.ts
│       │   └── redirect.ts
│       ├── package.json
│       └── tsconfig.json
├── src
  # NextJS files
├── stacks
│   ├── API.ts
│   ├── Database.ts
│   └── Site.ts
├── package.json
├── sst.config.ts
└── tsconfig.json
```

Both `packages/core` and `packages/functions` had separate `tsconfig.json` and `package.json` files, so they were independent submodules. However, SST's [NextJS example][sst-next] used a "mono package" setup, with a `functions/` folder at the top level that did not have its own `tsconfig.json` or `package.json`. I updated my project to use that pattern instead:

```text
.
├── functions
│   ├── core
│   │   ├── dynamo.ts
│   │   └── link.ts
│   ├── link
│   │   ├── create.ts
│   │   ├── get.ts
│   │   ├── list.ts
│   │   └── patch.ts
│   └── redirect.ts
├── src
  # NextJS files
├── stacks
│   ├── API.ts
│   ├── Database.ts
│   └── Site.ts
├── package.json
├── sst.config.ts
└── tsconfig.json
```

I'm not 100% sure what the issue was here. My guess is that the way Next projects are complied is different than how the submodule pattern expects to be compiled, and while SST can deploy that without issue, VSCode doesn't expect that setup and got confused. Neverless, I'm glad this was a relatively straightforward fix that lets me move forward.

## A Minor Rename

[One more thing][one-more]: I missed one rename earlier for `LinkEntity::service` name. It's a quick fix under (the renamed) `functions/core/link`:

```ts
export const LinkEntity = new Entity(
  {
    model: {
      entity: "links",
      version: "1",
      service: "shorty",
    },
    // ...
  }
)
```

These changes are in the PRs [**Switch from subpackages to one package**][pr-16] and [**Switch LinkEntity service name to shorty**][pr-17].

[research-1]: https://github.com/microsoft/vscode-eslint/issues/722
[research-2]: https://stackoverflow.com/questions/38268776/why-does-typescript-ignore-my-tsconfig-json-inside-visual-studio-code
[sst-next]: https://github.com/serverless-stack/sst/tree/master/examples/quickstart-nextjs
[sst-dynamo]: https://github.com/serverless-stack/sst/tree/master/examples/rest-api-dynamodb
[one-more]: https://www.youtube.com/watch?v=5SHMDMJPuwM
[pr-16]: https://github.com/nickymarino/shorty/pull/16
[pr-17]: https://github.com/nickymarino/shorty/pull/17
