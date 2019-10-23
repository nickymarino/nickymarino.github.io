---
layout: post
title: Calculating a Levenshtein Distance in Python and Swift
assets_folder: public/assets/2019/calculating-levenshtein-distance
---

Imagine you're writing a mobile app, and your user searches for the word `kitten`. Unfortunately, the only search terms you expected them to enter were from the following:

```
smitten
mitten
kitty
fitting
written
```

How do we figure out which word the user meant to type?

## Levenshtein Distances

A [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance) is a distance between two sequences `a` and `b`. If `a` and `b` are strings, the Levenshtein distance is the minimum amount of character edits needed to change one of the strings into the other. There are three types of edits allowed:

- Insertion: a character is added to `a`
- Deletion: a character is removed from `b`
- Substitution: a character is replaced in `a` or `b`

For example, if the first string `a = 'abc'` and the second string is `b = 'abc'`, the Levenshtein distance between the two strings is `0` because `a` and `b` are equal. If `a = 'abcd'` and `b = 'a'`, the distance is `3`. If `a = 'abcd'` and `b = 'aacc'`, the distance is `2`.

The definition of the Levenshtein distance for a string `a` with a length `i` and a string `b` with a length `j` is:

![](https://wikimedia.org/api/rest_v1/media/math/render/svg/4520f5376b54613a5b0e6c6db46083989f901821)

This definition is a recursive function. The first portion, `max(i, j) if min(i, j) = 0`, is the base cases where either the first string or the second string is empty.

The function `1_(ai != bi)` at the end of the third minimum element is the cost. If a[i] != b[i], the cost is 1, otherwise the cost is 0. The first minimum element is a deletion from `a`, the second is an insertion, and the third is a substitution.


## A Naive Implementation

First, let's implement a straightforward implementation in Swift. We'll create a function named `levenshtein_distance` and write the base cases to check whether either of the strings are empty:

```swift
func levenshtein_distance(a: String, b: String) -> Int {
    // If either array is empty, return the length of the other array
    if (a.count == 0) {
        return b.count
    }
    if (b.count == 0) {
        return a.count
    }
}
```

Then we add the recursive portion. We calculate the cost for the substitution, then find the minimum distance between the three different possible edits (deletion, insertion, or substitution):

```swift
func levenshtein_distance(a: String, b: String) -> Int {
    // ...

    // Check whether the last items are the same before testing the other items
    let cost = (a.last == b.last) ? 0 : 1

    let a_dropped = String(a.dropLast())
    let b_dropped = String(b.dropLast())

    return min(
        // Find the distance if an item in a is removed
        levenshtein_distance(a: a_dropped, b: b) + 1,
        // Find the distance if an item is removed from b (i.e. added to a)
        levenshtein_distance(a: a, b: b_dropped) + 1,
        // Find the distance if an item is removed from a and b (i.e. substituted)
        levenshtein_distance(a: a_dropped, b: b_dropped) + cost
    )
}
```

Let's test our distance function with a simple test case:

```swift
print(opti_leven_distance(a: "123", b: "12"))
```
```
1
```

More example test cases can be found below in the final files. And now we can compare the distances of our words to the string `kitten` to figure out which word the user probably meant to type:

```swift
// Print out the distances for our test case
let first_word = "kitten"
let test_words = ["smitten", "mitten", "kitty", "fitting", "written"]

for word in test_words {
    let dist = opti_leven_distance(a: first_word, b: word)
    print("Distance between \(first_word) and \(word): \(dist)")
}
```

```
Distance between kitten and smitten: 2
Distance between kitten and mitten: 1
Distance between kitten and kitty: 2
Distance between kitten and fitting: 3
Distance between kitten and written: 2
```

The user probably meant to type mitten instead of kitten!

## An Improved Implementation

The recursive implementation of the Levenshtein distance above won't scale very well for larger strings. What if we needed to find the distance between a thousand strings, each with hundreds of characters?

One improved way to calculate a Levenshtein distance is to use a matrix of distances to "remember" previously calculated distances. First, the distance function should check for empty strings. Then, we'll create a matrix to hold the distance calculations:

```swift
func opti_leven_distance(a: String, b: String) -> Int {
    // Check for empty strings first
    if (a.count == 0) {
        return b.count
    }
    if (b.count == 0) {
        return a.count
    }

    // Create an empty distance matrix with dimensions len(a)+1 x len(b)+1
    var dists = Array(repeating: Array(repeating: 0, count: b.count+1), count: a.count+1)
}
```

The first column and first row of the distance matrix are zeros as an initialization step. The next column goes from 1 to the length of `a` to represent removing each character to get to an empty string, and the next row goes from 1 to the length of `b` to represent adding (or inserting) each character to get to the value of `b`:

```swift
func opti_leven_distance(a: String, b: String) -> Int {
    //...

    // a's default distances are calculated by removing each character
    for i in 1...(a.count) {
        dists[i][0] = i
    }
    // b's default distances are calulated by adding each character
    for j in 1...(b.count) {
        dists[0][j] = j
    }
}
```

Similar to our naive implementation, we'll check the remaining indices in the distance matrix. This time, however, we'll use the previous values stored in the matrix to calculate the minimum distance rather than recursively calling the distance function. The final distance is the last element in the distance matrix (at the bottom right):

```swift
func opti_leven_distance(a: String, b: String) -> Int {
    //...

    // Find the remaining distances using previous distances
    for i in 1...(a.count) {
        for j in 1...(b.count) {
            // Calculate the substitution cost
            let cost = (a[i-1] == b[j-1]) ? 0 : 1

            dists[i][j] = min(
                // Removing a character from a
                dists[i-1][j] + 1,
                // Adding a character to b
                dists[i][j-1] + 1,
                // Substituting a character from a to b
                dists[i-1][j-1] + cost
            )
        }
    }

    return dists.last!.last!
}
```

We can use our test cases again to verify that our improved implementation is correct:

```swift
print(opti_leven_distance(a: "123", b: "12"))

// Print out the distances for our test case
let first_word = "kitten"
let test_words = ["smitten", "mitten", "kitty", "fitting", "written"]

for word in test_words {
    let dist = opti_leven_distance(a: first_word, b: word)
    print("Distance between \(first_word) and \(word): \(dist)")
}
```

```
1
Distance between kitten and smitten: 2
Distance between kitten and mitten: 1
Distance between kitten and kitty: 2
Distance between kitten and fitting: 3
Distance between kitten and written: 2
```

## Swift and Python Implementations

[Distance.playground](/public/assets/2019/calculating-levenshtein-distance/Distance.playground.zip):

```swift

import Foundation


/// Calculates the Levenshtein distance between two strings
/// - Parameter a: The first string
/// - Parameter b: The second string
func levenshtein_distance(a: String, b: String) -> Int {
    // If either array is empty, return the length of the other array
    if (a.count == 0) {
        return b.count
    }
    if (b.count == 0) {
        return a.count
    }

    // Check whether the last items are the same before testing the other items
    let cost = (a.last == b.last) ? 0 : 1

    let a_dropped = String(a.dropLast())
    let b_dropped = String(b.dropLast())

    return min(
        // Find the distance if an item in a is removed
        levenshtein_distance(a: a_dropped, b: b) + 1,
        // Find the distance if an item is removed from b (i.e. added to a)
        levenshtein_distance(a: a, b: b_dropped) + 1,
        // Find the distance if an item is removed from a and b (i.e. substituted)
        levenshtein_distance(a: a_dropped, b: b_dropped) + cost
    )
}

/// String extension to add substring by Int (such as a[i-1])
extension String {
    subscript (i: Int) -> Character {
      return self[index(startIndex, offsetBy: i)]
    }
}

/// A more optimized version of the Levenshtein distance function using an array of previously calculated distances
/// - Parameter a: The first string
/// - Parameter b: The second string
func opti_leven_distance(a: String, b: String) -> Int {
    // Check for empty strings first
    if (a.count == 0) {
        return b.count
    }
    if (b.count == 0) {
        return a.count
    }

    // Create an empty distance matrix with dimensions len(a)+1 x len(b)+1
    var dists = Array(repeating: Array(repeating: 0, count: b.count+1), count: a.count+1)

    // a's default distances are calculated by removing each character
    for i in 1...(a.count) {
        dists[i][0] = i
    }
    // b's default distances are calulated by adding each character
    for j in 1...(b.count) {
        dists[0][j] = j
    }

    // Find the remaining distances using previous distances
    for i in 1...(a.count) {
        for j in 1...(b.count) {
            // Calculate the substitution cost
            let cost = (a[i-1] == b[j-1]) ? 0 : 1

            dists[i][j] = min(
                // Removing a character from a
                dists[i-1][j] + 1,
                // Adding a character to b
                dists[i][j-1] + 1,
                // Substituting a character from a to b
                dists[i-1][j-1] + cost
            )
        }
    }

    return dists.last!.last!
}

/// Function to test whether the distance function is working correctly
/// - Parameter a: The first test string
/// - Parameter b: The second test string
/// - Parameter answer: The expected answer to be returned by the distance function
func test_distance(a: String, b: String, answer: Int) -> Bool {
    let d = opti_leven_distance(a: a, b: b)

    if (d != answer) {
        print("a: \(a)")
        print("b: \(b)")
        print("expected: \(answer)")
        print("distance: \(d)")
        return false
    } else {
        return true
    }
}

// Test the distance function with many different examples
test_distance(a: "", b: "", answer: 0)
test_distance(a: "1", b: "1", answer: 0)
test_distance(a: "1", b: "2", answer: 1)
test_distance(a: "12", b: "12", answer: 0)
test_distance(a: "123", b: "12", answer: 1)
test_distance(a: "1234", b: "1", answer: 3)
test_distance(a: "1234", b: "1233", answer: 1)
test_distance(a: "1248", b: "1349", answer: 2)
test_distance(a: "", b: "12345", answer: 5)
test_distance(a: "5677", b: "1234", answer: 4)
test_distance(a: "123456", b: "12345", answer: 1)
test_distance(a: "13579", b: "12345", answer: 4)
test_distance(a: "123", b: "", answer: 3)
test_distance(a: "kitten", b: "mittens", answer: 2)

print(opti_leven_distance(a: "123", b: "12"))

// Print out the distances for our test case
let first_word = "kitten"
let test_words = ["smitten", "mitten", "kitty", "fitting", "written"]

for word in test_words {
    let dist = opti_leven_distance(a: first_word, b: word)
    print("Distance between \(first_word) and \(word): \(dist)")
}
```

Here's a Python implementation of the Swift code above as [distance.py](/public/assets/2019/calculating-levenshtein-distance/distance.py). The Python version also can handle any `list` as well as any `str`

```python
# Calculates the Levenshtein distance between two strings
def levenshtein_distance(a, b):
    # If either array is empty, return the length of the other array
    if not len(a):
        return len(b)
    if not len(b):
        return len(a)

    # Check whether the last items are the same before testing the other items
    if a[-1] == b[-1]:
        cost = 0
    else:
        cost = 1

    return min(
        # Find the distance if an item in a is removed
        levenshtein_distance(a[:-1], b) + 1,
        # Find the distance if an item is removed from b (i.e. added to a)
        levenshtein_distance(a, b[:-1]) + 1,
        # Find the distance if an item is removed from a and b (i.e. substituted)
        levenshtein_distance(a[:-1], b[:-1]) + cost
    )

# A more optimized version of the Levenshtein distance function using an array of previously calculated distances
def opti_leven_distance(a, b):
    # Create an empty distance matrix with dimensions len(a)+1 x len(b)+1
    dists = [ [0 for _ in range(len(b)+1)] for _ in range(len(a)+1) ]

    # a's default distances are calculated by removing each character
    for i in range(1, len(a)+1):
        dists[i][0] = i
    # b's default distances are calulated by adding each character
    for j in range(1, len(b)+1):
        dists[0][j] = j

    # Find the remaining distances using previous distances
    for i in range(1, len(a)+1):
        for j in range(1, len(b)+1):
            # Calculate the substitution cost
            if a[i-1] == b[j-1]:
                cost = 0
            else:
                cost = 1

            dists[i][j] = min(
                # Removing a character from a
                dists[i-1][j] + 1,
                # Adding a character to b
                dists[i][j-1] + 1,
                # Substituting a character from a to b
                dists[i-1][j-1] + cost
            )

    return dists[-1][-1]

# Function to test whether the distance function is working correctly
def test_distance(a, b, answer):
    dist = opti_leven_distance(a, b)

    if dist != answer:
        print('a:', a)
        print('b:', b)
        print('expected:', answer)
        print('distance:', dist)
        print()

if __name__ == '__main__':
    # Test the distance function with many different examples
    test_distance('', '', 0)
    test_distance('1', '1', 0)
    test_distance('1', '2', 1)
    test_distance('12', '12', 0)
    test_distance('123', '12', 1)
    test_distance('1234', '1', 3)
    test_distance('1234', '1233', 1)
    test_distance([1, 2, 4, 8], [1, 3, 4, 16], 2)
    test_distance('', '12345', 5)
    test_distance([5, 6, 7, 7], [1, 2, 3, 4], 4)
    test_distance([1, 2, 3, 4, 5, 6], [1, 2, 3, 4, 5], 1)
    test_distance([1, 3, 5, 7, 9], [1, 2, 3, 4, 5], 4)
    test_distance([1, 2, 3], [], 3)
    test_distance('kitten', 'mittens', 2)



    first_word = 'kitten'
    test_words = ['smitten', 'mitten', 'kitty', 'fitting', 'written']
    for word in test_words:
        dist = opti_leven_distance(first_word, word)
        print(f'Distance between {first_word} and {word}: {dist}')
```