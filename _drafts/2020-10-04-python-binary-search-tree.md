---
layout: post
title: How to Write Your First Binary Search Tree
description: Examples of using and writing list comprehensions in Python
cover_image: 2020/python-binary-search-tree/tree-cover-image.png
image_folder: 2020/python-binary-search-tree
---

https://nickymarino.com/2020/09/23/python-walrus-operator/

For an extended example, let's create binary search tree (BST) and node classes with walrus operators. BSTs are efficient ways to organize large pieces of data as a collection and search for specific values. Wikipedia has a [great article](https://en.wikipedia.org/wiki/Binary_search_tree) on BSTs if you'd like to do a deep dive. First, we'll take a look at the structure of nodes, then we'll learn how to use walrus operators to add nodes to the tree.

### Nodes

In general, each node in a BST has:

- A value
- (Optional) a node to its left
- (Optional) a node to its right

In Python, our `Node` class has these same attributes:

```python
class Node:
    def __init__(self, value, right=None, left=None):
        self.value = value
        self.right = right
        self.left = left
```

### Inserting Nodes in the Tree

Larger values are towards the right of the tree, and lower values are towards the left of the tree. Every time you add a value to a BST, you first look at the root node. If the new value is higher than the root node's value, then look to the right.

You perform the same actions either way you look: if the direction (left or right) has a node, then you repeat the same process on that node. If the direction does not have a node, then you create a new node with the new value in that direction.

For example, if your BST has one node (the root node) with a value of 2 and you want to insert a new value of 5, you first look at the root node's value. In this example, the value of the root node is 2, which is less than 5. You look to the left of the root node and see that it is empty, so you create a new node with the value of 5, and you attach it to the left of the root node.

First, we'll need a `Tree` class that creates a root node on initialization, then it will add each other value as a new `Node` below the root node:

```python
class Tree:
    def __init__(self, values):
        self.root = Node(values[0])

        for value in values:
            self.insert(value)
```

#########

class Node:
    def __init__(self, value, right=None, left=None):
        self.value = value
        self.right = right
        self.left = left

    def __iter__(self):
        if left := self.left:
            for value in left:
                yield value

        yield self.value

        if right := self.right:
            for value in right:
                yield value

class Tree:
    def __init__(self, values):
        self.root = Node(values[0])

        for value in values:
            self.insert(value)

    def __iter__(self):
        return iter(self.root)

    def insert(self, value, node=None):
        node = node or self.root

        if (value == node.value):
            return

        if value < node.value:
            if left := node.left:
                self.insert(value, left)
            else:
                node.left = Node(value)
        elif value > node.value:
            if right := node.right:
                self.insert(value, right)
            else:
                node.right = Node(value)

my_tree = Tree([40, 35, 15, 25, 76, 42, 100, 80])
for value in my_tree:
    print(value)
