---
layout: post
title: "Hash Maps from Scratch Part 1: What is a Hash Map?"
description: In this first part, we will cover the three fundamental pieces of a hash map
cover_image: 2020/hash-maps-part-1/cover.png
image_folder: 2020/hash-maps-part-1
---

If you were designing a contacts app, how would you quickly access a phone number for a person given their name? You could keep an array of `Contact` objects and check each name:

```python
contacts = [ ... ]

def find_contact(name):
	for person in contacts:
		if person.full_name == name:
			return person
	return None
```

This won't scale very well if you have a lot of contacts though. What if your user has thousands of contacts on their phone?  Instead, you could create a database table, index by name, and use SQL to find the contact:

```python
db_connection = connect_to_db(...)

def find_contact(name):
	query = db_connection.sql(f'select * from contacts where name like {name}')
	return query.first_or_none()
```

Databases are great for this! But what if you're keeping a list of contacts locally for a short period of time? Maybe you don't want the hassle of maintaining a database for a small project, or you're designing an algorithm designed to solve a problem *really* fast. You can use a hash map!

### What is a Hash Map?

A hash map associates a `key` with a `value`. Think of a phone book, or, if you've never seen a phone book, think of the Contacts app on your phone. If you want to know someone's number, you look through your contact names, select the name you want, and that person's phone number is shown next to their name:

```
Johnson, Sally   317-111-1111
Whittler, Mica   431-222-2222
Rodrigo, John    228-333-3333
```

For a hash map to hold a list of contacts, the `key` could be a name, and the `value` could be a phone number. A `key` and a `value` together are called a *key value pair*.

![A key-value pair]({% include _functions/image_path.html name='Untitled_Artwork_2.png' %}){: .center}


Typically, a key is a primitive data type like an integer, float, or string. Values can be any type, such as a string, number, list, or object. Hash maps are called `dictionaries` (or `dicts`) in Python, and can be used in many contexts. Here's what a contacts `dict` might look like:

```python
contacts = {
	"Sally Johnson": "317-111-1111",
	"Mica Whittler": "317-222-2222",
	"John Rodrigo": "318-333-3333"
}

# Prints "317-111-1111"
print(contacts["Sally Johnson"])
```

A hash map has three main parts:

1. An *array* to hold items
2. A *hash function* to calculate the index of an item for the array, and
3. A method to handle hash collisions in the array (more on this later)

Let's walk through an example: Cave Johnson's phone number is 888-724-3623 (888-SCIENCE). In our contacts hash map, we want to insert the value `888-724-3623` with the key `Cave Johnson`.  Here's what the Python code might look like:

```python
# Create an empty dictionary (hash map)
contacts = {}

# Add the new contact
contacts["Cave Johnson"] = "888-724-3623"

# Prints '{"Cave Johnson": "888-724-3623"}'
print(contacts)

# Prints "888-724-3623"
print(contacts["Cave Johnson"])
```

Behind the scenes, the `contacts` dictionary will compute the hash, or index, of the key `Cave Johnson`, and insert the *key value pair* `("Cave Johnson", "888-724-3623")` at that index:

![A key-value pair is inserted into a bucket index]({% include _functions/image_path.html name='Untitled_Artwork_5.png' %}){: .center}


### How can I build a Hash Map?

Let's review the three main pieces we need to build a hash map:

1. An array to hold key value pairs
2. A hash function to generate indices for each key value pair, and
3. A data structure inside the array to handle hash collisions

Generally, a hash map's hash function will generate a unique index for any item inserted into the hash map. However, a hash function might return the same index for two different values, which is called a *hash collision* or *index collision*.

![Two values have the same hash value; a hash collision!]({% include _functions/image_path.html name='Untitled_Artwork_7.png' %}){: .center}


Hash maps must account for multiple key value pairs pointing to the same index. One way to account for index collisions is to create a linked list for each for each item in the main array. If two key value pairs are hashed to the same array index, the two pairs will be added to a linked list at that index:

![A hash map array, where each array item is a linked list]({% include _functions/image_path.html name='Untitled_Artwork_9.png' %}){: .center}


### Wrap Up

Hash maps are efficient data structures to associate `keys` with `values`. Hash maps use an array to hold key value pairs, a hash function to calculate the array index for each key value pair, and some data structure to account for index collisions.

To account for hash collisions in this series, each value of the hash map's array will be a linked list. If any new key value pair has the same index as a previous pair, then the new pair will be added to the end of that index's list. In the [next post]({{ site.url }}/2020/11/18/hash-maps-part-2), we'll learn how to build the linked list that we'll use in our hash map class.