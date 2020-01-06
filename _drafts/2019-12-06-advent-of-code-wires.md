---
layout: post
title: Fast Introduction to Node APIs
---

# Intro

https://adventofcode.com/2019/day/3

## Part 1

Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o), it goes right 8, up 5, left 5, and finally down 3:

...........
...........
...........
....+----+.
....|....|.
....|....|.
....|....|.
.........|.
.o-------+.
...........

Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:

...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........
These wires cross at two locations (marked X), but the lower-left one is closer to the central port: its distance is 3 + 3 = 6.

Here are a few more examples:

R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83 = distance 159
R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = distance 135
What is the Manhattan distance from the central port to the closest intersection?

## Part 2
It turns out that this circuit is very timing-sensitive; you actually need to minimize the signal delay.

To do this, calculate the number of steps each wire takes to reach each intersection; choose the intersection where the sum of both wires' steps is lowest. If a wire visits a position on the grid multiple times, use the steps value from the first time it visits that position when calculating the total value of a specific intersection.

The number of steps a wire takes is the total number of grid squares the wire has entered to get to that location, including the intersection being considered. Again consider the example from above:

...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........
In the above example, the intersection closest to the central port is reached after 8+5+5+2 = 20 steps by the first wire and 7+6+4+3 = 20 steps by the second wire for a total of 20+20 = 40 steps.

However, the top-right intersection is better: the first wire takes only 8+5+2 = 15 and the second wire takes only 7+6+2 = 15, a total of 15+15 = 30 steps.

# First crack

```python
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
    intersections = []
    for point in wires[0]:
        if point in wires[1]:
            intersections.append(point)

    intersections.pop(0)

    return intersections

# Return the closest manhattan distance between intersections
def findClosestDistance(intersections):
    return min(map(lambda point: abs(point[0]) + abs(point[1]), intersections))

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

# Part 1
# Print closest intersection point
print(findClosestDistance(findIntersections(wiresFromFile('in1.txt'))))

# Part 2
# Print earliest intersection point by wire length as (length, point)
print(findClosestIntersection(wiresFromFile('in1.txt')))
```

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