---
layout: post
title: >
  Dev Journal #7: Project Management via GitHub Projects
description:
cover_image: 2023/url-shortener/07-cover.png
image_folder: 2023/url-shortener
---

I'm pretty big into the productivity space; for a long while I bounced back and forth between [Todoist][todoist], [OmniFocus][omni], [Apple Reminders][reminders], and even a few [bullet journals][bujo]. These days, I'm heavily invested in Todoist, which begs the question: what's the best way to keep track of features, ideas, and tasks for this project?

While Todoist was an obvious option, I initially started with [GitHub Issues][gh-issues] for a few reasons:

- Issues are on the public repo, so they force me to [build in public][build-in-public].
- I can create new PRs from issues easily.
- Most open source projects use issues to track items, and this is a good sandbox to test out developer flows.

At first, I was throwing things into issues and gave them "labels" using suffixes like `Feature` and `DevOps`:

![List of GitHub issues for this repo]({% include _functions/image_path.html name='07-issues.png' %}){: .center}

I hit a few snags quickly though. For one, it takes a *lot* of clicking to rename titles or add new labels to each issue. Most importantly, I don't have a way of sorting issues by priority like a todo list.

GitHub projects was recently re-released and refreshed, so I decided to give it a go. It's still pretty easy to create a new project, and I honestly don't see much of a difference other than the list view is now the default.

![GitHub's "Create project" UI]({% include _functions/image_path.html name='07-new-project.png' %}){: .center}

After some tweaks, the [project][project] is in a place I'm happy with. It's a [kanban board][kanban] with three states:

1. **No Status:** These are ideas I'd like to do at some point in the future, but they're not critical to an MVP, such as improved error handling and a polished index page.
1. **Prioritized:** A ranked list of tasks that are critical to get the app working, where the top item is the one I want to do next.
1. **Done:** These are items that are complete and merged via PR.

I'm really happy with this setup; I can put all good ideas under **No Status**, I move the critical ones to **Prioritized**, and I only need to create issues for those that are actively on my plate to complete in the short term. Here's a snapshot of [the board][project]:

![Current kanban board]({% include _functions/image_path.html name='07-kanban-board.png' %}){: .center}

You can view the [issues for this repo here][issues] and the [kanban project here][project].

[todoist]: https://todoist.com/
[bujo]: https://bulletjournal.com/
[omni]: https://www.omnigroup.com/omnifocus/
[reminders]: https://support.apple.com/en-us/HT205890
[gh-issues]: https://github.com/features/issues
[build-in-public]: https://gabygoldberg.medium.com/the-building-in-public-how-to-guide-219d417f00c1
[project]: https://github.com/users/nickymarino/projects/2
[kanban]: https://www.atlassian.com/agile/kanban/boards
[issues]: https://github.com/nickymarino/url-shortener/issues
