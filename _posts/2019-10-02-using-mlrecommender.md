---
layout: post
title: How to Build a Song Recommender Using Create ML MLRecommender
---

<div class="alert">
    <p class="alert-title"><b>Beta Warning</b></p>
    <p class="alert-content">This example was written using macOS Catalina Version 10.15 Beta and Xcode Version 11.0 beta 5. Changes may have been made to the MLRecommender constructor since the time of writing.</p>
</div>

## Objective

By the end of this post, we'll learn how to use the [Create ML](https://developer.apple.com/documentation/createml) [`MLRecommender`](https://developer.apple.com/documentation/createml/mlrecommender) to recommend a song to a user given their listening history. We'll also learn how to parse and prepare an [`MLDataTable`](https://developer.apple.com/documentation/createml/mldatatable) using Python and data from a third party.

## Introduction to MLRecommender

A personalized recommendation system can be used in many different applications, such as a music player, video player, or social media site. A machine learning recommendation system compares a user's past activity to a large library of activity from many other users. For example, if Spotify wanted to recommend you a new Daily Mix, their ML recommendation system might look at your listening history for the past few weeks and compare that history to your friends' history. Our goal today is to create an `MLRecommender` to recommend songs to a user given their listening history.

The constructor for `MLRecommender` is:

```swift
init(trainingData: MLDataTable, userColumn: String, itemColumn: String, ratingColumn: String? = nil, parameters: MLRecommender.ModelParameters = ModelParameters()) throws
```

## Creating the Data Tables

The first step is to create the `trainingData` in the form of an `MLDataTable`. In this case, our training data is the listening history of many different users from the [Million Song Dataset](http://millionsongdataset.com), which holds the metadata for over a million songs and ratings provided by users.

We'll use two files from the dataset. The first is [`1000.txt`](https://static.turi.com/datasets/millionsong/10000.txt), which contains the user id, song id, and listen time for 10000 records. We'll call that `history.txt` from now on. The second is [`song_data.csv`](https://static.turi.com/datasets/millionsong/song_data.csv), which contains the song id, title, release date and artist name. We'll call that `songs.csv` from now on. All of the complete files for this tutorial can be found at the end of the post.

Here's what our input files look like. Notice that `songs.csv` has a header row while `history.txt` does not:

```
# history.txt

b80344d063b5ccb3212f76538f3d9e43d87dca9e	SOAKIMP12A8C130995	1
b80344d063b5ccb3212f76538f3d9e43d87dca9e	SOBBMDR12A8C13253B	2
b80344d063b5ccb3212f76538f3d9e43d87dca9e	SOBXHDL12A81C204C0	1
...
```
```
# songs.csv

song_id,title,release,artist_name,year
SOQMMHC12AB0180CB8,"Silent Night","Monster Ballads X-Mas","Faster Pussy cat",2003
SOVFVAK12A8C1350D9,"Tanssi vaan","Karkuteillä",Karkkiautomaatti,1995
SOGTUKN12AB017F4F1,"No One Could Ever",Butter,"Hudson Mohawke",2006
...
```

We'll be using the [pandas](https://pandas.pydata.org) Python library to handle our CSV data. First, download the files above and name them `history.txt` and `songs.csv`, and we'll load them:

```python
import csv
import pandas as pd

history_file = 'history.txt' # 'https://static.turi.com/datasets/millionsong/10000.txt'
songs_metadata_file = 'songs.csv' # 'https://static.turi.com/datasets/millionsong/song_data.csv'

# Import the files
history_df = pd.read_table(history_file, header=None)
history_df.columns = ['user_id', 'song_id', 'listen_count']
metadata_df =  pd.read_csv(songs_metadata_file)
```

`songs.csv` already has the column headers in the file, so we didn't need to add those like we did with `history_df`. This is what our dataframes now look like:
```
# history_df

                                    user_id             song_id  listen_count
0  b80344d063b5ccb3212f76538f3d9e43d87dca9e  SOAKIMP12A8C130995             1
1  b80344d063b5ccb3212f76538f3d9e43d87dca9e  SOBBMDR12A8C13253B             2
2  b80344d063b5ccb3212f76538f3d9e43d87dca9e  SOBXHDL12A81C204C0             1
...
```
```
# metadata_df
# (The '\' means that the row continues onto the next lines)

              song_id              title                release  \
0  SOQMMHC12AB0180CB8       Silent Night  Monster Ballads X-Mas
1  SOVFVAK12A8C1350D9        Tanssi vaan            Karkuteillä
2  SOGTUKN12AB017F4F1  No One Could Ever                 Butter

        artist_name  year
0  Faster Pussy cat  2003
1  Karkkiautomaatti  1995
2    Hudson Mohawke  2006
...
```

 Next, to create a single listening history for all users, we want to merge the song data in the `metadata_df` to the listening history in the `history_df` and create a CSV to use in Swift. Let's also add a column that combines the song title with the artist name so that we can see both in our `MLRecommender`:

```python
# Merge the files into a single csv
song_df = pd.merge(history_df, metadata_df.drop_duplicates(['song_id']), on="song_id", how="left")
song_df.to_csv('merged_listen_data.csv', quoting=csv.QUOTE_NONNUMERIC)

# Add a "Title - Name" column for easier printing later
song_df['song'] = song_df['title'] + ' - ' + song_df['artist_name']
```

Here's what our combined song dataframe now looks like:

```
# song_df

                                    user_id             song_id  listen_count  \
0  b80344d063b5ccb3212f76538f3d9e43d87dca9e  SOAKIMP12A8C130995             1
1  b80344d063b5ccb3212f76538f3d9e43d87dca9e  SOBBMDR12A8C13253B             2
2  b80344d063b5ccb3212f76538f3d9e43d87dca9e  SOBXHDL12A81C204C0             1

             title              release    artist_name  year  \
0         The Cove   Thicker Than Water   Jack Johnson     0
1  Entre Dos Aguas  Flamenco Para Niños  Paco De Lucia  1976
2         Stronger           Graduation     Kanye West  2007

                              song
0          The Cove - Jack Johnson
1  Entre Dos Aguas - Paco De Lucia
2            Stronger - Kanye West
...
```

As of the time of writing, `MLRecommender` requires that the item id column in  `trainingData` go from 1 to the number of items. In other words, if our `trainingData` included only three songs, `merged_listen_data.csv` would have song ids like `SOQMMHC12AB0180CB8`, `SOVFVAK12A8C1350D9`, and `SOGTUKN12AB017F4F1`, but we need to have song ids of `0`, `1`, and `2`. Let's add a new column to the CSV that uses incremental song ids from 0 to N:

```python
# Find the unique song ids
song_ids = metadata_df.song_id.unique()

# Create a new dataframe of the unique song ids and a new incremental
# id for each one
incremental_id_df = pd.DataFrame({'song_id': song_ids})
incremental_id_df['incremental_song_id'] = incremental_id_df.index

# Merge the original song metadata with the incremental ids
new_song_id_df = pd.merge(song_id_df, incremental_id_df, on='song_id', how='left')
new_song_id_df.to_csv('songs_incremental_id.csv', quoting=csv.QUOTE_NONNUMERIC)

# Create a new merged history and song metadata CSV with incremental ids
new_history_df = pd.merge(history_df, incremental_id_df, on='song_id', how='inner')
new_history_df.to_csv('merged_listen_data_incremental_song_id.csv', quoting=csv.QUOTE_NONNUMERIC)
```

Here's what our new song CSV file looks like. Notice that there's now an added column at the beginning with a song id from 0 to 999999:

```
# songs_incremental_id.csv

"","song_id","title","release","artist_name","year","incremental_song_id"
0,"SOQMMHC12AB0180CB8","Silent Night","Monster Ballads X-Mas","Faster Pussy cat",2003,0
1,"SOVFVAK12A8C1350D9","Tanssi vaan","Karkuteillä","Karkkiautomaatti",1995,1
2,"SOGTUKN12AB017F4F1","No One Could Ever","Butter","Hudson Mohawke",2006,2
...
```

And here's what our final merged listening data looks like with the incremental ids, ready to be read by the `MLRecommender`:

```
# merged_listen_data_incremental_song_id.csv

"","Unnamed: 0","user_id","song_id","listen_count","title","release","artist_name","year","incremental_song_id"
0,0,"b80344d063b5ccb3212f76538f3d9e43d87dca9e","SOAKIMP12A8C130995",1,"The Cove","Thicker Than Water","Jack Johnson",0,397069
1,18887,"7c86176941718984fed11b7c0674ff04c029b480","SOAKIMP12A8C130995",1,"The Cove","Thicker Than Water","Jack Johnson",0,397069
2,21627,"76235885b32c4e8c82760c340dc54f9b608d7d7e","SOAKIMP12A8C130995",3,"The Cove","Thicker Than Water","Jack Johnson",0,397069
...
```

Now we're ready to load it into the recommender!

## Using `MLRecommender`

Create a new Swift Playground, and add the two CSVs `merged_listen_data_incremental_song_id.csv` and `songs_incremental_id.csv` as resources to your Playground. For help on adding resources to a Swift Playground, check out [this post](https://medium.com/code-data/how-to-add-resources-to-your-swift-playground-d80c61ca3f9b). **Make sure your Swift Playground is a blank macOS Playground and not an iOS Playground**. Because our `MLRecommender` will only give us the user id and incremental song id when generating recommendations, we'll use the second CSV to view the song titles.

First, let's load the merged listening history with incremental ids:

```swift
import Foundation
import CreateML

// Create an MLDataTable from the merged CSV data
let history_csv = Bundle.main.url(forResource: "merged_listen_data_incremental_song_id", withExtension: "csv")!
let history_table = try MLDataTable(contentsOf: history_csv)
print(history_table)
```

```
Columns:
    X1	string
    Unnamed: 0	integer
    user_id	string
    song_id	string
    listen_count	integer
    title	string
    release	string
    artist_name	string
    year	integer
    incremental_song_id	integer
Rows: 2000000
Data:
+----------------+----------------+----------------+----------------+----------------+
| X1             | Unnamed: 0     | user_id        | song_id        | listen_count   |
+----------------+----------------+----------------+----------------+----------------+
| 0              | 0              | b80344d063b5...| SOAKIMP12A8C...| 1              |
| 1              | 18887          | 7c8617694171...| SOAKIMP12A8C...| 1              |
| 2              | 21627          | 76235885b32c...| SOAKIMP12A8C...| 3              |
| 3              | 27714          | 250c0fa2a77b...| SOAKIMP12A8C...| 1              |
| 4              | 34428          | 3f73f44560e8...| SOAKIMP12A8C...| 6              |
| 5              | 34715          | 7a4b8e7d2905...| SOAKIMP12A8C...| 6              |
| 6              | 55885          | b4a678fb729b...| SOAKIMP12A8C...| 2              |
| 7              | 65683          | 33280fc74b16...| SOAKIMP12A8C...| 1              |
| 8              | 75029          | be21ec120193...| SOAKIMP12A8C...| 1              |
| 9              | 105313         | 6fbb9ff93663...| SOAKIMP12A8C...| 2              |
+----------------+----------------+----------------+----------------+----------------+
+----------------+----------------+----------------+----------------+---------------------+
| title          | release        | artist_name    | year           | incremental_song_id |
+----------------+----------------+----------------+----------------+---------------------+
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
| The Cove       | Thicker Than...| Jack Johnson   | 0              | 397069              |
+----------------+----------------+----------------+----------------+---------------------+
[2000000 rows x 10 columns]
```

From there, we can create an `MLRecommender`. Our `trainingData` is the data table format of the merged listening history CSV, the `userColumn` is the `user_id` column name and the `itemColumn` is the `incremental_song_id` column name. The `user_id` of `b80344d063b5ccb3212f76538f3d9e43d87dca9e` was randomly picked from the merged CSV data:=.

```swift
// Generate recommendations
let recommender = try MLRecommender(trainingData: history_table, userColumn: "user_id", itemColumn: "incremental_song_id")
let recs = try recommender.recommendations(fromUsers: ["b80344d063b5ccb3212f76538f3d9e43d87dca9e"])
print(recs)
```

```
Columns:
    user_id	string
    incremental_song_id	integer
    score	float
    rank	integer
Rows: 10
Data:
+----------------+---------------------+----------------+----------------+
| user_id        | incremental_song_id | score          | rank           |
+----------------+---------------------+----------------+----------------+
| b80344d063b5...| 114557              | 0.0461493      | 1              |
| b80344d063b5...| 834311              | 0.0436045      | 2              |
| b80344d063b5...| 939015              | 0.043068       | 3              |
| b80344d063b5...| 955047              | 0.0427589      | 4              |
| b80344d063b5...| 563380              | 0.0426116      | 5              |
| b80344d063b5...| 677759              | 0.0423951      | 6              |
| b80344d063b5...| 689170              | 0.0418951      | 7              |
| b80344d063b5...| 333053              | 0.041788       | 8              |
| b80344d063b5...| 381319              | 0.0403042      | 9              |
| b80344d063b5...| 117491              | 0.0400819      | 10             |
+----------------+---------------------+----------------+----------------+
[10 rows x 4 columns]
```

But we want to know the song metadata associated with each recommended `incremental_song_id`. Let's load the song metadata table and join the recommendations with the song metadata using the incremental id:

```swift
// Use the songs data CSV to print the recommended song titles
let songs_csv = Bundle.main.url(forResource: "songs_incremental_id", withExtension: "csv")!
let songs_table = try MLDataTable(contentsOf: songs_csv)
print(songs_table)

let song_title_recs = recs.join(with: songs_table, on: "incremental_song_id")
print(song_title_recs)
```
```
Columns:
    X1	string
    song_id	string
    title	undefined
    release	string
    artist_name	string
    year	integer
    incremental_song_id	integer
Rows: 1000000
Data:
+----------------+----------------+----------------+----------------+----------------+
| X1             | song_id        | title          | release        | artist_name    |
+----------------+----------------+----------------+----------------+----------------+
| 0              | SOQMMHC12AB0...| Silent Night   | Monster Ball...| Faster Pussy...|
| 1              | SOVFVAK12A8C...| Tanssi vaan    | Karkuteillä   | Karkkiautoma...|
| 2              | SOGTUKN12AB0...| No One Could...| Butter         | Hudson Mohawke |
| 3              | SOBNYVR12A8C...| Si Vos Querés | De Culo        | Yerba Brava    |
| 4              | SOHSBXH12A8C...| Tangle Of As...| Rene Ablaze ...| Der Mystic     |
| 5              | SOZVAPQ12A8C...| Symphony No....| Berwald: Sym...| David Montgo...|
| 6              | SOQVRHI12A6D...| We Have Got ...| Strictly The...| Sasha / Turb...|
| 7              | SOEYRFT12AB0...| 2 Da Beat Ch...| Da Bomb        | Kris Kross     |
| 8              | SOPMIYT12A6D...| Goodbye        | Danny Boy      | Joseph Locke   |
| 9              | SOJCFMH12A8C...| Mama_ mama c...| March to cad...| The Sun Harb...|
+----------------+----------------+----------------+----------------+----------------+
+----------------+---------------------+
| year           | incremental_song_id |
+----------------+---------------------+
| 2003           | 0                   |
| 1995           | 1                   |
| 2006           | 2                   |
| 2003           | 3                   |
| 0              | 4                   |
| 0              | 5                   |
| 0              | 6                   |
| 1993           | 7                   |
| 0              | 8                   |
| 0              | 9                   |
+----------------+---------------------+
[1000000 rows x 7 columns]


Columns:
    user_id	string
    incremental_song_id	integer
    score	float
    rank	integer
    X1	string
    song_id	string
    title	undefined
    release	string
    artist_name	string
    year	integer
Rows: 11
Data:
+----------------+---------------------+----------------+----------------+----------------+
| user_id        | incremental_song_id | score          | rank           | X1             |
+----------------+---------------------+----------------+----------------+----------------+
| b80344d063b5...| 114557              | 0.0461493      | 1              | 114578         |
| b80344d063b5...| 117491              | 0.0400819      | 10             | 117512         |
| b80344d063b5...| 333053              | 0.041788       | 8              | 333174         |
| b80344d063b5...| 381319              | 0.0403042      | 9              | 381465         |
| b80344d063b5...| 381319              | 0.0403042      | 9              | 444615         |
| b80344d063b5...| 563380              | 0.0426116      | 5              | 563705         |
| b80344d063b5...| 677759              | 0.0423951      | 6              | 678222         |
| b80344d063b5...| 689170              | 0.0418951      | 7              | 689654         |
| b80344d063b5...| 834311              | 0.0436045      | 2              | 834983         |
| b80344d063b5...| 939015              | 0.043068       | 3              | 939863         |
+----------------+---------------------+----------------+----------------+----------------+
+----------------+----------------+----------------+----------------+----------------+
| song_id        | title          | release        | artist_name    | year           |
+----------------+----------------+----------------+----------------+----------------+
| SOHENSJ12AAF...| Great Indoors  | Room For Squ...| John Mayer     | 0              |
| SOOGZYY12A67...| Crying Shame   | In Between D...| Jack Johnson   | 2005           |
| SOGFKJE12A8C...| Sun It Rises   | Fleet Foxes    | Fleet Foxes    | 2008           |
| SOECLAD12AAF...| St. Patrick'...| Room For Squ...| John Mayer     | 0              |
| SOECLAD12AAF...| St. Patrick'...| Room For Squ...| John Mayer     | 0              |
| SOAYTRA12A8C...| All At Once    | Sleep Throug...| Jack Johnson   | 2008           |
| SOKLVUI12A67...| If I Could     | In Between D...| Jack Johnson   | 2005           |
| SOYIJIL12A67...| Posters        | Brushfire Fa...| Jack Johnson   | 2000           |
| SORKFWO12A8C...| Quiet Houses   | Fleet Foxes    | Fleet Foxes    | 2008           |
| SOJAMXH12A8C...| Meadowlarks    | Fleet Foxes    | Fleet Foxes    | 2008           |
+----------------+----------------+----------------+----------------+----------------+
[11 rows x 10 columns]
```

The last table printed has our recommended songs, and the first one is "Great Indoors"! We can now use our `MLRecommender` for other user ids.

## Wrap Up

First, we took a look at the `MLRecommender` constructor. Then, we gathered song data from the Million Song Dataset. We modified the dataset to increase legibility and added incremental ids for the song metadata. We loaded the song metadata and listening history into a Swift Playground, created an `MLRecommender` from the listening history and generated recommended songs. Then, we used the song metadata to join the recommended songs to their titles and artists.

## Source Files

Each of the files mentioned in this tutorial can be found [here](https://drive.google.com/open?id=1uONrROKv8lfMX1-4LBPo4fh9Y18ZYNA2), including:

- `songs.csv`: Metadata for one million songs
- `history.txt`: Song listening history for multiple users
- `data-parser.py`: Python code to manipulate the Million Song Dataset
- `merged_listed_data.csv`: Merged dataset of song metadata and listening history
- `merged_listed_data_incremental_song_id.csv`: `merged_listed_data.csv` with incremental ids added
- `songs_incremental_id.csv`: `songs.csv` with incremental ids added
- `MusicRecommender.playground`: Swift Playground for creating the MLRecommender

_This blog post was inspired by Eric Le's_ [How to build a simple song recommender system](https://towardsdatascience.com/how-to-build-a-simple-song-recommender-296fcbc8c85).
