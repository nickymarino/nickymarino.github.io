---
layout: post
title: Building a Full-Stack Serverless URL Shortener
description: Learn how to build your own URL shortener from scratch using serverless architecture. Follow this comprehensive guide to leverage AWS services like DynamoDB, Lambda, API Gateway, and Cognito. Enhance your full-stack development skills and create a scalable URL shortener that suits your needs. Get started today!
cover_image: 2023/url-shortener/01-arch-diagram.png
image_folder: 2023/url-shortener
---

**I'm going to strengthen my fullstack serverless developer skills by building a clone of [bitly][bitly].**

This idea came from a conversation I had with a friend of mine, who hosts parties often and manage the invite lists with a Telegram chat. He wanted to create fancy invitations by embossing a link to the chat as a QR code, and to do that he needed to create a rubber stamp for the QR code.

Custom rubber stamps are pretty expensive, and so I suggested that the QR code point to a shortened URL. That way, he can change the URL later without creating a new stamp. To which he replied:

> "I'll use bitly to create the invite link, of course."

Now don't get me wrong, bitly is great for non-technical folks to create shortened URLs. However, especially after [Heroku ended their free tier][heroku-next-chapter], I've learned that there's no such thing as a free lunch. I'm immediately leery of any free service that services a *lot* of people without a very obvious market strategy behind it.

So, it's about time I build my own URL shortener! I have plenty of use cases for it, it's a great side project to learn how to write fullstack apps, and I can always open it up to my friends to use as well.

[heroku-next-chapter]: https://blog.heroku.com/next-chapter
[bitly]: https://bitly.com/

## A Foray into Developer Journals

Inspired by [Juraj Majerik's diary of an Uber clone][uber-diary] and [David Smith's design diary][ds-diary], my plan is to write short blog posts on the days I work on this project. In a perfect world, I'd like to devote at least an hour daily to this, but I'm aiming to make a post at least once a week until completion.

[uber-diary]: https://jurajmajerik.com/blog/start-here/
[ds-diary]: https://www.david-smith.org/dnd/

## Architecture Overview

Before I get started, I drafted what I expect my tech stack to look like in broad strokes. Additional context I used:

- Unlike most side projects, this is one I hope to use personally going forward.
- At work, our stack is [AWS][aws] and [SST][sst] for infrastructure, and [React][react] and [MUI][mui] for the frontend.

[aws]: https://aws.amazon.com/what-is-aws/
[react]: https://react.dev/
[sst]: https://docs.sst.dev/
[mui]: https://mui.com/

Here's my plan for the architecture:

![Architecture diagram of the URL shortener]({% include _functions/image_path.html name='01-arch-diagram.png' %}){: .center}

I'm going to use [SST][sst] to manage the infrastructure and stitching all the pieces together. For the API backend, the data store will be a [DynamnoDB][dynamo] [mono-table][mono-table], and the compute will be [AWS Lambda][lambda] functions behind an [API Gateway][api-gateway]. [AWS Cognito][cognito] will manage the user authentication and authorization.

[lambda]: https://aws.amazon.com/lambda/
[api-gateway]: https://aws.amazon.com/api-gateway/
[cognito]: https://aws.amazon.com/cognito/
[mono-table]: https://aws.amazon.com/blogs/compute/creating-a-single-table-design-with-amazon-dynamodb/
[dynamo]: https://aws.amazon.com/dynamodb/


I'm really excited to embark on this journey. By documenting my progress in short blog posts, I hope to share my experiences and insights with others who may be interested in similar projects. Stay tuned for future updates as I delve into the development process and bring this project to life. Let's build something amazing together!