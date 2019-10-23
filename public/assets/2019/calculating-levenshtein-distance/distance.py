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
