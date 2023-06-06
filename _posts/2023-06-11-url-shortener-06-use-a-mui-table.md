---
layout: post
title: >
  Dev Journal #6: Add a MUI table component
description:
cover_image: 2023/url-shortener/06-cover.png
image_folder: 2023/url-shortener
---

Next, let's use a proper MUI table component to display the list of links. At first, I toyed with using [MUI X's Data Grid component][mui-data-grid], but because it was an additional package with a freemium model, I decided to use a more basic display for the first crack.

MUI's [basic table example][basic-table] is pretty good, so we'll more or less lift that and modify it slightly to show our link-specific columns in `src/pages/index.tsx`:

```ts
function LinkTable({ links }: { links: Link[] }) {
  function toTimestamp(epoch: number) {
    return new Date(epoch).toString();
  }

  return (
    <Table sx={{ '{{' }} minWidth: 650 }} aria-label="simple table">
      <TableHead>
        <TableRow>
          <TableCell>Short Path</TableCell>
          <TableCell>URL</TableCell>
          <TableCell>Created</TableCell>
          <TableCell>Updated</TableCell>
        </TableRow>
      </TableHead>
      <TableBody>
        {links.map((row) => (
          <TableRow
            key={row.uid}
            sx={{ '{{' }} "&:last-child td, &:last-child th": { border: 0 } }}
          >
            <TableCell component="th" scope="row">
              {row.shortPath}
            </TableCell>
            <TableCell>{row.url}</TableCell>
            <TableCell>{toTimestamp(row.createdAt)}</TableCell>
            <TableCell>{toTimestamp(row.updatedAt)}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

We'll use the new `LinkTable` component on the `Home` page in the same file:

```ts
export default function Home({ links }: { links?: Link[] }) {
  console.log({ links });
  return (
    <Container maxWidth="lg">
      {/* ... */}
        {links && LinkTable({ links })}
```

And then our links show up in a neat table! You can view this stage of the project on the [**Use table for link list**][pr-11] PR. Here's what the UI looks like now:

![Links show in a table on the UI]({% include _functions/image_path.html name='06-mui-table-for-links.png' %}){: .center}

[mui-data-grid]: https://mui.com/x/react-data-grid/
[basic-table]: https://mui.com/material-ui/react-table/#basic-table
[pr-11]: https://github.com/nickymarino/url-shortener/pull/11
