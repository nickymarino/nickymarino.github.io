---
layout: post
title: Fast Introduction to Node APIs
---

By the end of this post, we will have created an API using Node, [express](https://expressjs.com) and [body-parser](node body parser json). Our API will have two endpoints: `/magic-8-ball` will return a random [Magic 8-Ball](https://en.wikipedia.org/wiki/Magic_8-Ball) response, and `/to-zalgo` will convert given text into [Zalgo](https://stackoverflow.com/questions/6579844/how-does-zalgo-text-work) text.


# Setup

First, create a new folder named `node-api` and navigate to it. We need to create a new npm package that will hold our API app. Run the following command and fill out the information. Each part can be left the default, except the entry point should be `app.js`:

```bash
$ npm init
```

Next, let's install `express` and `body-parser`, as we'll need both later:

```bash
$ npm install express body-parser
```

In order to run our app, we'll add a command inside `package.json` for `npm start`. Add this item to the `"scripts"` array:

```javascript
  "scripts": {
    ...
    "start": "node app.js"
  },
```

# Express Hello World

Now that we have our package set up, we can begin writing the web app. Let's return "Hello world!" at the root of our app (`/`, or `http://localhost:3200/`):

```javascript
// Load the modules we installed
const express = require('express')
const bodyparser = require('body-parser')

// Tell express to run the webserver on port 3200
const app = express();
const port = process.env.port || 3200

// Use body-parser for unencoding API request bodies - more on this later
app.use(bodyparser.json())
app.use(bodyparser.urlencoded({ extended: false }))

app.listen(port, () => {
    console.log(`running on port ${port}`)
})

// Return "Hello world" when you go to http://localhost:3200
app.get('/', (req, res) => res.send('Hello world!'))
```

To test our app, run `npm start` in one terminal window, then use `curl` in the other:

```bash
$ curl http://localhost:3200
Hello world!
```

# Magic 8-Ball Responses

Our first API endpoint, `/magic-8-ball`, will return a JSON result in the form of `{"prediction": "<8-ball response>"}`. I wrote a helper function to return a random item from an array:

```javascript
function randomItemFromArray(arr) {
    return arr[Math.floor(Math.random() * arr.length)]
}
```

Then all we need to do is have our server keep an array of possible responses, pick a random one, and return the response in JSON format:

```javascript
// Return a random response for http://localhost:3200/magic-8-ball
// {"prediction": "<random_prediction>"}
app.get('/magic-8-ball', (req, res) => {
    const responses = [
        'It is certain.',
        'It is decidedly so.',
        'Without a doubt.',
        'Yes - definitely.',
        'You may rely on it.',
        'As I see it, yes.',
        'Most likely.',
        'Outlook good.',
        'Yes.',
        'Signs point to yes.',
        'Reply hazy, try again.',
        'Ask again later.',
        'Better not tell you now.',
        'Cannot predict now.',
        'Concentrate and ask again.',
        "Don't count on it.",
        'My reply is no.',
        'My sources say no.',
        'Outlook not so good.',
        'Very doubtful.'
    ]

    res.status(200).json({
        prediction: randomItemFromArray(responses)
    })
})
```

Run `npm start`, and we can test it a few times using `curl`:

```bash
$ curl http://localhost:3200/magic-8-ball
{"prediction":"Without a doubt."}

$ curl http://localhost:3200/magic-8-ball
{"prediction":"Yes - definitely."}

$ curl http://localhost:3200/magic-8-ball
{"prediction":"Signs point to yes."}
```

# Zalgo Text

Our Zalgo endpoint (`/to-zalgo`) is a little more advanced. A user will send a POST request including a message in the form `{"text": "your text here"}`, and the endpoint will return a response in the form `{"code": 200, "original": "your text here", "zalgo": "zalgo-ified text"}`. The endpoint will also return a 400 HTTP Status Code error if the input data is incorrect:

```javascript
// Return Zalgo-ified text for http://localhost:3200/to-zalgo
// Input:   {"text": "your text here"}
// Returns: {"code": 200, "original": "your text here", "zalgo": "zalgo-ified text"}
app.post('/to-zalgo', (req, res) => {
    // Return 400 if the input doesn't contain a "text" element
    if (req.body.text === undefined) {
        res.status(400).json({
            "code": 400,
            "message": "Missing 'text' argument"
        })
        return
    }

    original = req.body.text
    zalgo = toZalgo(original)

    res.status(200).json({
        "code": 200,
        "original": original,
        "zalgo": zalgo
    })
})
```

Let's test it a few times with `curl`. To send data in a POST request, like our text in JSON format, use `-d "data"`. Because we're sending data in a JSON format, our requests via `curl` will need to include `-H "Content-Type: application/json"` as well.

(If you're wondering why the text looks odd, I'd recommend checking out another [Zalgo converter](https://lingojam.com/ZalgoText) first)

```bash
$ curl -d '{"text":"Sphinx of black quartz, judge my vow"}' -H "Content-Type: application/json" http://localhost:3200/to-zalgo
{"code":200,"original":"Sphinx of black quartz, judge my vow","zalgo":"S̡̲̳͔̻ͤ̏ͦ̾̀͒̀p̰̯̐̃͒͂ͪͨͤ͘͠h̷̖̰̩̍ͯi̸̩̜͇̪͍͉̭ͨ͐̆͞ͅn̡̧̤̭͚̤̯̼̹ͪͫ́̌ͫ̇̑̋ͅx̧̻̤̄ͩ͋ͣ͂ ̥̤̩̳̠͖ͧ͡ͅö͍̮̅ͯ̋ͣf̠͎̗͕̯̈́̀͑̐͌͊̍͒́ͅ ̦̬̱͉̫͍̞ͤͯͦ͂͜b̡̼̱̊ͅl̵̻̹͇̘̒̌̊̄aͩ̏͛̋̇̅̇ͩ̀͏̘̳̲̫͕ͅc̢̛̗̱͗́̓̆̌k̡͉͉̼̾̍̒͌̀ ̡̳͈͓̞̦̞̱̥̒̌ͦ̅̃q̰̪̟̥̿̀͝ȕ̗a͓̟͍͐̓̂ͣ̀͜r̞̭̪̦̩̹̂̒̐͗̕t̺͎͛̿̽͒̑̓̆ͧz̸͖̟͓̪̻͓̝̦ͨ̕,̻͔͙̲̓̈ͮ̍ ͍̘̟̖̩͊̀̈́ͩͯ̑j̷͕̱̖̔ͧ͌u̗̱͈ͨ̄ͩͬd̜̖̖̦̺̟́̇͐͛̒̆͊ͦ͜g̎ͩͅe̪̟̦͓̥̘͙ͭ̊ͨ̓ ͔̳̒̔̈̈́̈͠ͅm̧̪̊̌y̧͂̑ͯͤ͏͔͔͓͕̮ ̸̛͎͚͇͔̭̱̱͐ͮ̐ͪ͐̊͌v̘̬̘͋̅̽̅̄̐̀o̵̤̝̯̞̪̍͞ͅw̶̠̝̦̹͔̍ͪ͐̂ͮͭ̌͟"}

{"code":200,"original":"the blood of the ancients resides within me","zalgo":"t͍̗͖͚͙͖͖̿ͪ̍h͍̘̩̤̼̞̫̜̒͟ȩ̛̺̫̖̝̰̥͋͛̎̎̈̈ ̢̼̫͈͓ͦ̿ͯb̺̖͚̤͓̲͓ͬ͊ͬ͑̅l̼̪̞̮͖̩̥͕̎ͧ̓̋̐̒ͧͯö̱̹͔̫͇́͌ͭͩ̉̆ͬ͆͠ͅô̸̶̲̫̞͔̻̝̰͓͋d̹̫̠͚͉͎ͨ͑ͯ̀ ̨̫͍̹̺̰̑͛̂̾͗ͪ̓ͅô͙̰͍͓̯͍̼̟ͭ́̽̑́͐̓f̯̥͙͈̺̮̙̙̅̌͂̓ͦ ̸͚̝̥̮̅̾t̨̟̗̟̼͔̑ͥ̊̾ͧͮ̿̿h̜̉͋ͮ͐e̪̳ͧ̾̏ ͬͤ̄̽̾̈̓͊͏̖̗̪͖͚a̢̩̖̯̹͗̊̽͢n̴̔ͥ̓͐͏̙̞̙̭̞͉c̖͕̘̗͉̠̬͂ͤͦ͋ì͕̥̱͍̗̐̅̆̓ͫe̮̩̩̮̬͕͈̾͂͒ͪ͛̇͞n̸̳̹̗͊ͦ̋ͅt͎̯̖̟̫ͯͪs͔̮͋ͧͩ͋̏ͯ̆͢ ̺̤̘̫̗̻̂r̡͚̮͇̘̻͔̉ͅĕ͔̪͖͓̯̙͙͗̂ͯ͛ͭs̵̝̘̺̠̘ͬͮi̴͖̤̟̭͚̞ͪͣd̶̛̪͈̉e͉̺̖̫ͥ̔̽̂̄͒́ͬ́́ͅṡ̵͕͟ͅ ̷̜̤̝̹̦̼͖̅ͭ̈͌͐̍ͦ͗ͅw̧̠͍̻̜͆̔ͣ͗͜i̵̶̙͉̺̦̲̅͋t̗̽͑͐ͣ̇ͣ͛ͧh̢̗͍͎̪̪̹̳̎͗̑̔̎̏͛͜i̶̱̪̺̖̻͓ͥ̿ͨ̇̅̔͗̎ͅņ̪ͬ̇ͭ̉ͬͩ͢ ̶̨̲̩̙ͦ̔̈́̄m̡̳̬̟͐e̱̩̠̙ͨ̓̇̽͑̋"}
```
# Conclusion

Now our API has two endpoints, `/magic-8-ball` and `/to-zalgo` for you to use as a starting point for your own web app.

Here's the full version of our `app.js`:

```javascript
// Load the modules we installed
const express = require('express')
const bodyparser = require('body-parser')
var toZalgo = require('to-zalgo')

// Tell express to run the webserver on port 3200
const app = express();
const port = process.env.port || 3200

// Use body-parser for unencoding API request bodies - more on this later
app.use(bodyparser.json())
app.use(bodyparser.urlencoded({ extended: false }))

app.listen(port, () => {
    console.log(`running on port ${port}`)
})

// Return "Hello world" when you go to http://localhost:3200
app.get('/', (req, res) => res.send('Hello world!'))

// Return a random response for http://localhost:3200/magic-8-ball
// Returns: {"prediction": "<random_prediction>"}
app.get('/magic-8-ball', (req, res) => {
    const responses = [
        'It is certain.',
        'It is decidedly so.',
        'Without a doubt.',
        'Yes - definitely.',
        'You may rely on it.',
        'As I see it, yes.',
        'Most likely.',
        'Outlook good.',
        'Yes.',
        'Signs point to yes.',
        'Reply hazy, try again.',
        'Ask again later.',
        'Better not tell you now.',
        'Cannot predict now.',
        'Concentrate and ask again.',
        "Don't count on it.",
        'My reply is no.',
        'My sources say no.',
        'Outlook not so good.',
        'Very doubtful.'
    ]

    res.status(200).json({
        prediction: randomItemFromArray(responses)
    })
})

// Return Zalgo-ified text for http://localhost:3200/to-zalgo
// Input:   {"text": "your text here"}
// Returns: {"code": 200, "original": "your text here", "zalgo": "zalgo-ified text"}
app.post('/to-zalgo', (req, res) => {
    // Return 400 if the input doesn't contain a "text" element
    if (req.body.text === undefined) {
        res.status(400).json({
            "code": 400,
            "message": "Missing 'text' argument"
        })
        return
    }

    original = req.body.text
    zalgo = toZalgo(original)

    res.status(200).json({
        "code": 200,
        "original": original,
        "zalgo": zalgo
    })
})

function randomItemFromArray(arr) {
    return arr[Math.floor(Math.random() * arr.length)]
}
```

The entire example app can be found as a [GitHub repo](https://github.com/nickymarino/node-text-api) as well.
