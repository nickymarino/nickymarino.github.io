---
layout: post
title: >
  Dev Journal #1: API create links
description:
# cover_image: 2023/url-shortener/01-arch-diagram.png
# image_folder: 2023/url-shortener
---

Let's set up some backend API functions, but first we need a project we can code against. [SST's docs][sst-nextjs] recommend starting with a clean NextJS app then add sst on top by running these scripts in the root folder:

```text
npx create-next-app@latest

npx create-sst@latest
npm install
```

We'll use SST to create a new DynamoDb table in `stacks/Database.ts`. Because we're going to have two primary access patterns on the table immediately--GET by URL and GET by unique id--we'll add one global index to handle the second access pattern:

```ts
export function Database({ stack }: StackContext) {
  const table = new Table(stack, "table", {
    fields: {
      pk: "string",
      sk: "string",
      gsi1pk: "string",
      gsi1sk: "string",
    },
    primaryIndex: {
      partitionKey: "pk",
      sortKey: "sk",
    },
    globalIndexes: {
      gsi1: {
        partitionKey: "gsi1pk",
        sortKey: "gsi1sk",
      },
    },
  });

  return { table };
}
```

And we'll similarly create an API in `stacks/API.ts` to create a link as `POST /link` backed by a lambda function:

```ts
function nameFor(shortName: string) {
  const nameGenerator = (props: FunctionNameProps): string => {
    return `${props.stack.stackName}-${shortName}`;
  };
  return nameGenerator;
}

export function API({ stack }: StackContext) {
  const { table } = use(Database);

  const api = new Api(stack, "api", {
    defaults: {
      function: {
        bind: [table],
      },
    },
    routes: {
      "POST /link": {
        function: {
          functionName: nameFor("LinkCreate"),
          handler: "packages/functions/src/link/create.handler",
        },
      },
    },
  });
  stack.addOutputs({
    ApiEndpoint: api.url,
  });

  return { api };
}
```

Here, `nameFor` is my shorthand to create nicer function names. By default, SST will let CloudFormation auto-generate the function names, and they're pretty unreadable. `nameFor` will pass a name generator into SST as it creates functions so that the function names are human readable.

Let's also update `sst.config.ts` with the `Database` and `API` stacks:

```ts
export default {
  config(_input) {
    return {
      name: "cow-link",
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

We're following [recommendations in SST's documentation][sst-electrodb] to use [ElectroDB][electrodb] as our DynamoDB interface, so we add `ulid`, `electrodb`, and the AWS DynamoDB client to our dependencies in `package.json`:

```json
  "dependencies": {
    "ulid": "^2.3.0",
    "electrodb": "^2.5.1",
    "@aws-sdk/client-dynamodb": "^3.332.0"
  }
```

We'll need to configure ElectroDB with the details about the DynamoDB table, so let's add that in `packages/core/src/dynamo.ts`:

```ts
export const Client = new DynamoDBClient({});

export const Configuration: EntityConfiguration = {
  table: Table.table.tableName,
  client: Client,
};
```

And we'll need a `LinkEntity` with a corresponding `create` function in `packages/core/src/link.ts`:

```ts
export const LinkEntity = new Entity(
  {
    model: {
      entity: "links",
      version: "1",
      service: "cowlinks",
    },
    attributes: {
      uid: {
        type: "string",
        required: true,
      },
      shortPath: {
        type: "string",
        required: true,
      },
      url: {
        type: "string",
        required: true,
      },
    },
    indexes: {
      byUid: {
        pk: {
          field: "pk",
          composite: [],
        },
        sk: {
          field: "sk",
          composite: ["uid"],
        },
      },
      byShortPath: {
        index: "gsi1pk-gsi1sk-index",
        pk: {
          field: "gsi1pk",
          composite: ["shortPath"],
        },
        sk: {
          field: "gsi1sk",
          composite: [],
        },
      },
    },
  },
  Dynamo.Configuration
);

export async function create(shortPath: string, url: string) {
  const result = await LinkEntity.create({
    uid: ulid(),
    shortPath,
    url,
  }).go();

  return result.data;
}
```

Last but certainly not least, we'll write the code backing the lambda function to actually create links. To start, let's create a hardcoded link to test under `packages/functions/link/create.ts`:

```ts
export const handler = ApiHandler(async (_evt) => {
  const newLink = await Link.create("test", "https://google.com");

  return {
    body: {
      link: newLink,
    },
  };
});
```

You can view this code in the [**Add link create**][create-commit] commit.

[sst-nextjs]: https://sst.dev/examples/how-to-create-a-nextjs-app-with-serverless.html
[sst-electrodb]: https://docs.sst.dev/learn/write-to-dynamodb
[electrodb]: https://github.com/tywalch/electrodb
[create-commit]: https://github.com/nickymarino/url-shortener/commit/7f55e809bd70d791daddb52aa22efd39bb582a91
