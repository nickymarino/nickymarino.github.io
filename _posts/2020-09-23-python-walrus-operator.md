---
layout: post
title: Python's Walrus Operator
description: Examples of how to use the walrus operator in Python 3.8
cover_image: 2020/python-walrus-operator/walrus_cover.png
---

> Beautiful is better than ugly.
>
>  &mdash; [The Zen of Python](https://www.python.org/dev/peps/pep-0020/)

Python introduced a brand new way to assign values to variables in version 3.8.0. The new syntax is `:=`, and it's called a "walrus operator" because it looks like a pair of eyes and a set of tusks. The walrus operator assigns values as part of a larger expression, and it can significantly increase legibility in many areas.

## Named Expressions

You can create *named expressions* with the walrus operator. Named expressions have the format `NAME := expression`, such as `x := 34` or `numbers := list(range(10))`. Python code can use the `expression` to evaluate a larger expression (such as an `if` statement), and the variable `NAME` is assigned the value of the expression.

If you've written Swift code before, Python's walrus operator is similar to Swift's  [Optional Chaining](https://docs.swift.org/swift-book/LanguageGuide/OptionalChaining.html). With optional chaining, you assign a value to a variable inside the conditional of an `if` statement. If the new variable's value is not `nil` (like Python's `None`), the `if` block is executed. If the variable's value is `nil`, then the block is ignored:

```swift
let responseMessages = [
    200: "OK",
    403: "Access forbidden",
    404: "File not found",
    500: "Internal server error"
]

let response = 444
if let message = responseMessages[response] {
    // This statement won't be run because message is nil
    print("Message: " + message)
}
```

## Benefits

There are a lot of benefits to using the walrus operator in your code. But don't take my word for it! Here's what the authors of the idea said in their proposal:

> Naming the result of an expression is an important part of programming, allowing a descriptive name to be used in place of a longer expression, and permitting reuse.
>
> &mdash; [PEP 572 -- Assignment Expressions](https://www.python.org/dev/peps/pep-0572/#rationale)

Let's take a look at some examples.

### Don't Repeat Yourself

With the walrus operator, you can more easily stick to the [DRY principle](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) and reduce how often you repeat yourself in code.  For example, if you want to print an error message if a list is too long, you might accidentally get the length of the list twice:

```python
my_long_list = list(range(1000))

# You get the length twice!
if len(my_long_list) > 10:
    print(f"List is too long to consume (length={len(my_long_list)}, max=10)")
```

Let's use the walrus operator to only find the length of the list once *and* keep that length inside the scope of the `if` statement:

```python
my_long_list = list(range(1000))

# Much better :)
if (count := len(my_long_list)) > 10:
    print(f"List is too long to consume (length={count}, max=10)")
```

In the code block above, `count := len(my_long_list)` assigns the value `1000` to `count`. Then, the `if` statement is evaluated as `if len(my_long_list) > 10`. The walrus operator has two benefits here:

1. We don't calculate the length of a (possibly large) list more than once
2. We clearly show a reader of our program that we're going to use the `count` variable inside the scope of the `if` statement.

### Reuse Variables

Another common example is using Python's regular expression library, `re`. We want to look at a list of phone numbers and print their area codes if they have one. With a walrus operator, we can check whether the area code exists and assign it to a variable with one line:

```python
import re

phone_numbers = [
    "(317) 555-5555",
    "431-2973",
    "(111) 222-3344",
    "(710) 982-3811",
    "290-2918",
    "711-7712",
]

for number in phone_numbers:
    # The regular expression "\(([0-9]{3})\)" checks for a substring
    # with the pattern "(###)", where # is a 0-9 digit
    if match := re.match("\(([0-9]{3})\)", number):
        print(f"Area code: {match.group(1)}")
    else:
        print("No area code")
```

### Legible Code Blocks

A common programming pattern is performing an action, assigning the result to a variable, and then checking the result:

```python
result = parse_field_from(my_data)
if result:
    print("Success")
```

In many cases, these types of blocks can be cleaned up with a walrus operator to become one indented code block:

```python
if result := parse_field_from(my_data):
    print("Success")
```

These blocks can be chained together to convert a nested check statements into one line of if/elif/else statements. For example, let's look at some students in a dictionary. We need to print each student's graduation date if it exists, or their student id if available:

```python
sample_data = [
    {"student_id": 200, "name": "Sally West", "graduation_date": "2019-05-01"},
    {"student_id": 404, "name": "Zahara Durham", "graduation_date": None},
    {"student_id": 555, "name": "Connie Coles", "graduation_date": "2020-01-15"},
    {"student_id": None, "name": "Jared Hampton", "graduation_date": None},
]

for student in sample_data:
    graduation_date = student["graduation_date"]
    if graduation_date:
        print(f'{student["name"]} graduated on {graduation_date}')
    else:
        # This nesting can be confusing!
        student_id = student["student_id"]
        if student_id:
            print(f'{student["name"]} is currently enrolled with ID {student_id}')
        else:
            print(f'{student["name"]} has no data")
```

With walrus operators, we can put the graduation date and student id checks next to each other, and better show that we're checking for one or the other for each student:

```python
sample_data = [
    {"student_id": 200, "name": "Sally West", "graduation_date": "2019-05-01"},
    {"student_id": 404, "name": "Zahara Durham", "graduation_date": None},
    {"student_id": 555, "name": "Connie Coles", "graduation_date": "2020-01-15"},
    {"student_id": None, "name": "Jared Hampton", "graduation_date": None},
]

for student in sample_data:
    # Much cleaner
    if graduation_date := student["graduation_date"]:
        print(f'{student["name"]} graduated on {graduation_date}')
    elif student_id := student["student_id"]:
        print(f'{student["name"]} is currently enrolled with ID {student_id}')
    else:
        print(f'{student["name"]} has no data")
```

## Wrap Up

With walrus operators and named expressions, we can dramatically increase the legibility of our code by simplifying statements, reusing variables, and reducing indentation. For more great examples, check out the [original proposal](https://www.python.org/dev/peps/pep-0572/#examples) and the Python 3.8  [release notes](https://docs.python.org/3/whatsnew/3.8.html#what-s-new-in-python-3-8).

