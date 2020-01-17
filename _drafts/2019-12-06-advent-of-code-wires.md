---
layout: post
title: Fast Introduction to Node APIs
---

## Intro

[Advent of Code](https://adventofcode.com/) is a fun, annual Advent calendar of small programming challenges. This post will be a walkthrough of a few solutions to the 2019 [Advent of Code Day 3](https://adventofcode.com/2019/day/3). We'll first solve the problem in a straightforward way, and then we'll improve the time and space complexity of our solution.

I encourage you to read the [full challenge](https://adventofcode.com/2019/day/3), but below is a condensed version. Our challenge is to identify intersections in two wires laid out in a plane:

> To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the [Manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry) for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.
>
> ...
>
> (Part A) What is the Manhattan distance from the central port to the closest intersection?
>
> ...
>
> (Part B) What is the fewest combined steps the wires must take to reach an intersection?

Let's walk through a brief example to understand the problem.

## Example

Let's say we have two wires as input, `R4,U4` and `U4,R4`, that both start at the same origin `o`:

```
.......
.+---X.
.|...|.
.|...|.
.|...|.
.o---+.
.......
```

Wire 1 has four pieces going right from the center `o` and four pieces up. Wire 2 has four pieces going up from the center `o` and four pieces right. The two wires intersect at the point `X`.

For Part A, we just need to calculate the [Manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry) from `o` to `X`, which is `4 + 4 = 8`. For Part B, each wire takes `4 + 4 = 8` steps to reach the intersection `X`, so the answer is `8 + 8 = 16`. The [full challenge](https://adventofcode.com/2019/day/3) has a few more examples you can check out.

## First Solution

First, let's try to solve the problem in a straightforward way. Once we understand the problem and the solution, we can optimize our code.

Let's assume that the input to our script is one file, with each wire on a separate line. Our data structure for a wire will be a `list`, where each item is a wire portion. Each wire portion will be another `list` including an X and Y coordinate. For example, for our first wire `R4,U4`, the wire will be represented as `[0, 0], [1, 0], [2, 0]... [4, 3], [4, 4]`.

### Setup: Wire Creation

The function to create a wire will have a list of steps in the wire, such as `['R4', 'U4']`. We'll create the wire by going through each step, determining the direction, and adding the wire portions to the list. For example, if we start at point `[0, 0]`, and have a first step of `D2`, then our wire will be represented as `[0, 0], [0, -1], [0, -2]`.


```python
def wireFromSteps(steps):
    '''Return a wire data structure given a list of steps (from an input file)'''
    # Start at the origin
    wire = [[0, 0]]
    lastStep = wire[0]

    # Iterate over each step (R4, D6, ...)
    for step in steps:
        for _ in range(int(step[1:])):
            # Figure out the next wire segment coordinate
            if step[0] == 'R':
                nextStep = [lastStep[0] + 1, lastStep[1]]
            elif step[0] == 'L':
                nextStep = [lastStep[0] - 1, lastStep[1]]
            elif step[0] == 'U':
                nextStep = [lastStep[0], lastStep[1] + 1]
            else:  # D
                nextStep = [lastStep[0], lastStep[1] - 1]

            # Add the wire segment
            wire.append(nextStep)
            lastStep = nextStep

    return wire
```

||example output of first wire||

To create the wires from the file, we need a function to read the file, and split the text by newlines. We'll also need to split each line on the commas to pass the right input to `wireFromSteps`:

```python
def wiresFromFile(filename):
    '''Return a list of wires from a file'''
    with open(filename) as f:
        wires = []

        # Calculate the segments for each wire
        for line in f.readlines():
            steps = [i.strip() for i in line.split(',')]
            wires.append(wireFromSteps(steps))

    return wires
```

||example input file for wire1,2||
||example output for two basic wires||

### Part A: Finding the Closest Manhattan Distance

Now that we're able to read our input and generate corresponding wire data structures, we can find the closest intersection. First, let's find all of the intersections between the two wires[^optimize].

[^optimize]: If you're thinking there may be a few more optimal ways to solve either part, you're right! we'll get to a few optimization techniques later in this post.

We'll find the intersections by looking at each segment (such as `[1, 2]`) in the first wire. If the same segment is in the second wire, we'll store the intersection in a list. (Note that this approach may be slow for long wires! Checking if an item exists in a list has a time complexity of `O(n)`. The optimization section below addresses this issue.)

```python
def findIntersections(wires):
    '''Find all intersections between the two wires (except [0, 0])'''
    intersections = []

    # Add any section that's in both wires
    for point in wires[0]:
        if point in wires[1]:
            intersections.append(point)

    # Remove the origin intersection [0, 0], which will always exist
    # first and won't be an answer to any wires with length > 1
    intersections.pop(0)

    return intersections
```

||example with wires1,2||

To solve Part A, we need to find the minimum Manhattan distance of all of the intersections to the origin. We need a function to calculate a Manhattan distance. Because the origin is at `[0, 0]`, the Manhattan distance for any point is the sum of absolute values of the x- and y-coordinates:

```python
def manhattanDistance(intersection):
    '''Return the Manhattan distance for an intersection'''
    return abs(intersection[0]) + abs(intersection[0])
```

To find the smallest distance, we can use `map` to call the function `manhattanDistance` on each intersection:

```python
def findClosestDistance(intersections):
    '''Return the closest manhattan distance between intersections'''
    return min(map(manhattanDistance, intersections))

```

### Part B: Finding the Closest Combined Steps

To solve Part B, we first need to find a way to calculate the combined distances along the wire segments for an intersection. Because each wire is represented by the segments, the distance along the wire is encoded into the index of the segment in the list. For example, consider a wire that begins with segments `[0, 0], [1, 0], ...`. The first segment away from the origin is `[1, 0]`, which has an index of 1 in the wire list and a distance of 1 along the wire. We can use the index of a segment in a wire list as the distance along the wire.

```python
### TEST THIS CODE ###
def findClosestIntersection(wires):
    intersections = []
    for idx, point in enumerate(wires[0][1:]):
        if point in wires[1]:
            firstClosest = (idx+1, point)
            break

    for idx, point in enumerate(wires[1][1:]):
        if point in wires[0]:
            secondClosest = (idx+1, point)
            break

    return firstClosest if firstClosest[0] < secondClosest[0] else secondClosest
```

# Use example test from aoc

# Part 1
# Print closest intersection point
print(findClosestDistance(findIntersections(wiresFromFile('in1.txt'))))

# Part 2
# Print earliest intersection point by wire length as (length, point)
print(findClosestIntersection(wiresFromFile('in1.txt')))


# use second examle/question to show that it takes too long, need to optimize

# Second crack

```python
import functools

# Return a wire data structure given a list of steps (from an input file)
def wireFromSteps(steps):
    wire = [[0, 0]]
    lastStep = wire[0]
    for step in steps:
        for _ in range(int(step[1:])):
            if step[0] == 'R':
                nextStep = [lastStep[0] + 1, lastStep[1]]
            elif step[0] == 'L':
                nextStep = [lastStep[0] - 1, lastStep[1]]
            elif step[0] == 'U':
                nextStep = [lastStep[0], lastStep[1] + 1]
            else:  # D
                nextStep = [lastStep[0], lastStep[1] - 1]

            wire.append(nextStep)
            lastStep = nextStep
    return wire

# Return a list of wires from a file
def wiresFromFile(filename):
    with open(filename) as f:
        wires = []
        for line in f.readlines():
            steps = [i.strip() for i in line.split(',')]
            wires.append(wireFromSteps(steps))
    return wires

# Find all intersections between the two wires (except [0, 0])
def findIntersections(wires):
    sets = []
    for wire in wires:
        newSet = set([tuple(i) for i in wire])
        sets.append(newSet)

    intersectionSet = functools.reduce(lambda x,y: x & y, sets)
    intersectionSet.remove( (0, 0) )
    return list(intersectionSet)

# Return the closest manhattan distance between intersections
def findClosestDistance(intersections):
    return min(map(lambda point: abs(point[0]) + abs(point[1]), intersections))

def findClosestIntersection(wires, intersections):
    bestDistance = 100000
    bestPoint = []

    ### NEED +1 still?
    wire1dists = { tuple(point): idx+1 for idx, point in enumerate(wires[0]) }
    wire2dists = { tuple(point): idx+1 for idx, point in enumerate(wires[1]) }

    for point in intersections:
        dist1 = wire1dists[point]
        dist2 = wire2dists[point]

        totalDist = dist1 + dist2
        if totalDist < bestDistance:
            bestDistance = totalDist
            bestPoint = point

    return (bestDistance, bestPoint)

# Part 1
# Print closest intersection point
print(findClosestDistance(findIntersections(wiresFromFile('in2.txt'))))

# Part 2
# Print earliest intersection point by wire length as (length, point)
wires = wiresFromFile('in2.txt')
intersections = findIntersections(wires)
print(findClosestIntersection(wires, intersections))
```

# Third crack

- store wire1 as a dict { (point), dist }
- iterate over every point in wire2 and check with wire1, rather than storing both

_These solutions were developed by me with a few colleagues at an Algorithm Special Interest Group meeting hosted by [ChiPy](https://www.chipy.org/). If you're in the Chicago area and like Python, I'd recommend checking out their events!_