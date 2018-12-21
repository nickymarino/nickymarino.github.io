---
layout: post
title: Web API and Templates with Python requests and Jinja2
image_folder: 2018/web-apis-and-templates
---

# Introduction

[Web APIs](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Client-side_web_APIs/Introduction) are becoming an [increasingly popular](https://code.tutsplus.com/articles/the-increasing-importance-of-apis-in-web-development--net-22368) method to retrieve and store data, and they can be an extremely powerful tool for any programmer. In this walkthrough, you will use GroupMe's [public API](https://dev.groupme.com/docs/v3) to retrieve the last few messages in a group and display it using a custom HTML template in Python 3.7.1:

![Output Website]({% include _functions/image_path.html name='output-site.png' %})

While we'll be using specific GroupMe API endpoints, this walkthrough will help you to learn the basics of working with web APIs in general.

## Set up

Before we begin, you need to have the following modules installed:

- `requests` (for connecting to the API)
- `jinja2` (for adding data to our template)

# Using a Web API

## Working with `requests`

The `requests` library is great for creating HTTP requests, and it has fantastic [documentation](http://docs.python-requests.org/en/master/). We'll be using `requests.get(url)` to get the information we need:

```python
>>> import requests
>>> # Use JSONPlaceHolder as an example
>>> req = requests.get('https://jsonplaceholder.typicode.com/todos/1')
>>> print(req.text)
{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

## Create an Application

To use GroupMe's API, we need to first register an application to get our API key. Log into the [developer application page](https://dev.groupme.com/session/new) and click "Create Application". You'll be taken to this page:

![Create Application Page]({% include _functions/image_path.html name='create-application.png' %})

We won't be using the Callback URL, so set that to any valid URL. Fill in the developer information and submit the form, and you'll be taken to the application's detail page:

![Application Page]({% include _functions/image_path.html name='application-access-token.png' %})

Copy the Access Token at the bottom of the application page. That'll be our API key.

## Find the Group ID

To get messages in a group, we'll first need to get the group's ID. GroupMe's [documentation](https://dev.groupme.com/docs/v3) says to use the base url `https://api.groupme.com/v3` and has the following example using `curl`:

```bash
$ curl -X POST -H "Content-Type: application/json" -d '{"name": "Family"}' https://api.groupme.com/v3/groups?token=YOUR_ACCESS_TOKEN
```

From this, we know that the url we use with `requests.get()` will be in the form[^url-params]

```
https://api.groupme.com/v3/...?token=YOUR_ACCESS_TOKEN
```

Looking at the [groups API](https://dev.groupme.com/docs/v3#groups), we can use `GET /groups` to retrieve a list of our most recent groups:

```python
>>> import requests
>>> API_KEY = 'YOUR_API_KEY'
>>> base_url = 'https://api.groupme.com/v3'
>>> req = requests.get(f'{base_url}/groups?token={API_KEY}')
>>> req.content
b'{"response":[{"id":"1111","group_id":"2222","name":"My Group Name","phone_number":"+1 5555555555","type":"private","description":"Group description goes here",
...
```

First, we construct the url for the API request and pass it as the argument to `requests.get()`. Then, we print the result of the API request stored as `req.content`.

The response we get from GroupMe is a JSON-formatted string, so we'll move our script into its own file and parse the string using Python's standard `json` library:

```python
import json
import requests

API_KEY = 'YOUR_API_KEY'
BASE_URL = 'https://api.groupme.com/v3'

def api_request(request):
    '''Returns the data from a request (eg /groups)'''
    url = f'{BASE_URL}{request}?token={API_KEY}'
    req = requests.get(url)

    if not req.content:
        return None

    # We only want the data associated with the "response" key
    return json.loads(req.content)['response']

if __name__ == '__main__':
    groups = api_request('/groups')
    print(len(groups), 'group(s)')
    for group in groups:
        print(f'ID {group["group_id"]}: {group["name"]}')
```

The function `api_request` does the work of creating the final URL string for us. Then, it makes the request and checks that something was returned by GroupMe's servers. If something was sent back to us, the content is converted[^json-object] from a string into a Python object using `json.loads()`. Finally, we return the data associated with the key `response`, because the rest is metadata unimportant to us.

When we run the script, our most recent groups are returned (as a JSON object decoded into a Python object). The result will tell us the group names and their group IDs:

```
3 group(s)
ID 11111111: Python Tips and Tricks
ID 22222222: University Friend Group
ID 33333333: GitHub Chat
```

## Get Messages for a Group

We have a list of our group IDs, so we can use the following API to get a list of recent messages for one group:

```
GET /groups/<group_id>/messages
```

Let's add this endpoint to our script as `get_messages_for_group(group_id)`:

```python
import json
import requests

API_KEY = 'YOUR_API_KEY'
BASE_URL = 'https://api.groupme.com/v3'

def api_request(request):
    '''Returns the data from a request (eg /groups)'''
    url = f'{BASE_URL}{request}?token={API_KEY}'
    req = requests.get(url)

    if not req.content:
        return None

    # We only want the data associated with the "response" key
    return json.loads(req.content)['response']

def get_messages_for_group(group_id):
    response = api_request(f'/groups/{group_id}/messages')

    # Just return the messages (and none of the metadata)
    return response['messages']

if __name__ == '__main__':
    messages = get_messages_for_group(YOUR_GROUP_ID)
    print(messages[0])
```

Our script will get the messages for a group (fill in `YOUR_GROUP_ID`) and print the most recent one. Running it will print something like:

```
{'attachments': [], 'avatar_url': None, 'created_at': 1544810700, 'favorited_by': [], 'group_id': '11112233', 'id': '882882828288288282', 'name': 'Johnny Test', 'sender_id': '22558899', 'sender_type': 'user', 'source_guid': 'android-11111111-3eee-4444-9999-aaaabbbbcccc', 'system': False, 'text': "Hello everyone!", 'user_id': '55551111'}
```

We can see from the message's data that the sender's name "Jonny Test" and the text was "Hello everyone!" Next, we should organize our API results as Python objects to be easier to expand on.

## Creating Classes for API Objects

Now that we're ready to start processing the data from the API, it's a good time to create objects to represent our API objects. With Python classes, we can keep only the data we need and begin to process our own information. We'll initialize our API objects by passing them the decoded Python object from `api_request(request)`. This way, we can more easily add class properties without needing to change our request function.

Let's make two classes, `Group` and `Message`:

```python
class Message:
    def __init__(self, json):
        self.user_id = json['user_id']
        self.name = json['name']
        self.text = json['text']

class Group:
    def __init__(self, json):
        self.id = json['group_id']
        self.name = json['name']
        self.messages = []
```

Then we can add a method to `Group` to fetch its recent messages:

```python
def get_recent_messages(self):
    messages = get_messages_for_group(self.id)

    # Convert each message to our object
    for message in messages:
        new_message_object = Message(message)
        self.messages.append(new_message_object)
```

And then we can use our script to print out the messages for a group:

```python
import json
import requests

API_KEY = 'YOUR_API_KEY'
BASE_URL = 'https://api.groupme.com/v3'

def api_request(request):
    '''Returns the data from a request (eg /groups)'''
    url = f'{BASE_URL}{request}?token={API_KEY}'
    req = requests.get(url)

    if not req.content:
        return None

    # We only want the data associated with the "response" key
    return json.loads(req.content)['response']

def get_messages_for_group(group_id):
    response = api_request(f'/groups/{group_id}/messages')

    # Just return the messages and none of the metadata
    return response['messages']

class Message:
    def __init__(self, json):
        self.user_id = json['user_id']
        self.name = json['name']
        self.text = json['text']

class Group:
    def __init__(self, json):
        self.id = json['group_id']
        self.name = json['name']
        self.messages = []
        self.get_recent_messages()

    def get_recent_messages(self):
        messages = get_messages_for_group(self.id)

        # Convert each message to our object
        for message in messages:
            new_message_object = Message(message)
            self.messages.append(new_message_object)

if __name__ == '__main__':
    groups_json = api_request('/groups')
    my_group = Group(groups_json[0])

    for message in my_group.messages:
        print(message.text)
        print(f'-- {message.name}')
        print()
```

The result is the most recent messages for our most recent group:

```
Hello everyone!
-- Johnny Test

Hi guys I had a question about using @classmethod
-- Alexa Jones

Wow great work!
-- Katie Alendra
```

We have the data in a manageable format, so it's time to start formatting it in a readable form.

# Using Jinja Templates

We've come a long way so far! First, we learned how to make HTTP GET requests to a server. Then, we used GroupMe's API docs to fetch data about different groups and messages, and then we created Python classes to better organize our information. Let's create a [Jinja](http://jinja.pocoo.org/docs/2.10/) template to print out our data.

## Create the Template

First, I'll make a `group.html` file that has the framework of I want the web page to look like:

```html
<body>
    <h1>GROUP NAME</h1>
    <br />

    <!-- Repeat for every message -->
    <p><b>MESSAGE CONTENT</b> &mdash; NAME</p>
</body>
```

With Jinja, variables are inserted into the template using `{% raw %}{{ variable_name }}{% endraw %}`, and logic statements have a form such as:

```jinja
{% raw %}
{% if should_display %}
    <p>This message should be displayed</p>
{% endif %}
{% endraw %}
```

If we assume that we'll pass a `Group()` instance into our Jinja template with the variable name `group`, we can rewrite `group.html` as:

```html
{% raw %}
<body>
    <h1>{{ group.name }}</h1>
    <br />

    <!-- Repeat for every message -->
    {% for message in group.messages %}
    <p><b>{{ message.text }}</b> &mdash;{{ message.name }}</p>
    {% endfor %}
</body>
{% endraw %}
```

Note the {% raw %}`{% endif %}` and `{% endfor %}`{% endraw %} in the above snippets; they're required for all conditionals and loops.

## Populate the Template

With our template written, let's go back to our script and add a section to import our template using `jinja2`.

```python
with open('group.html', 'r') as f:
    contents = f.read()

template = jinja2.Template(contents)
filled_template = template.render(group=my_group)

with open('output.html', 'w') as f:
    f.write(filled_template)
```

First, we read the contents of our template file. Because we're only going to use one file, we can just load the text of our template into `jinja2.Template`, and then we can render the template by passing our `my_group` variable (from our main script) as `group`. Finally, we write the contents to `output.html` to view it in a browser.

Now we have our full script:

```python
import json
import jinja2
import requests

API_KEY = 'YOUR_API_KEY'
BASE_URL = 'https://api.groupme.com/v3'

def api_request(request):
    '''Returns the data from a request (eg /groups)'''
    url = f'{BASE_URL}{request}?token={API_KEY}'
    req = requests.get(url)

    if not req.content:
        return None

    # We only want the data associated with the "response" key
    return json.loads(req.content)['response']

def get_messages_for_group(group_id):
    response = api_request(f'/groups/{group_id}/messages')

    # Just return the messages and none of the metadata
    return response['messages']

class Message:
    def __init__(self, json):
        self.user_id = json['user_id']
        self.name = json['name']
        self.text = json['text']

class Group:
    def __init__(self, json):
        self.id = json['group_id']
        self.name = json['name']
        self.messages = []
        self.get_recent_messages()

    def get_recent_messages(self):
        messages = get_messages_for_group(self.id)

        # Convert each message to our object
        for message in messages:
            new_message_object = Message(message)
            self.messages.append(new_message_object)

if __name__ == '__main__':
    groups_json = api_request('/groups')
    my_group = Group(groups_json[0])

    with open('group.html', 'r') as f:
        contents = f.read()

    template = jinja2.Template(contents)
    filled_template = template.render(group=my_group)

    with open('output.html', 'w') as f:
        f.write(filled_template)
```

Once run, we can view our `output.html` in a browser:

```html
<body>
    <h1>Python Tips and Tricks</h1>
    <br />

    <!-- Repeat for every message -->
    <p><b>Hello everyone!</b> &mdash;Johnny Test</p>
    <p><b>Hi guys I had a question about using @classmethod</b> &mdash;Alexa Jones</p>
    <p><b>Wow great work!</b> &mdash;Katie Alendra</p>
</body>
```

![Output Website]({% include _functions/image_path.html name='output-site.png' %})

# Conclusion

We've walked through how to access and parse a web API using the requests library, how to represent and organize the API data using Python classes, and how to render the information in a custom format using a Jinja template. Now go create your own cool stuff using APIs!

---

[^url-params]: We won't in this walkthrough, but ff we needed to pass multiple [parameters](https://en.wikipedia.org/wiki/Query_string#Web_forms) in the URL, it'll look like `v3/...?limit=10&another_param=1000&token=YOUR_ACCESS_TOKEN`)

[^json-object]: Typically, `json.loads`() returns a dict that can contain more dicts, lists, and values like `None`, strings, and integers. Check out the [Python docs](https://docs.python.org/3/library/json.html) for examples.