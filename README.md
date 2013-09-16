[![Build Status](https://api.travis-ci.org/oisin/verbosnarf.png?branch=master)](https://travis-ci.org/oisin/verbosnarf)

Small app to read and store AWS S3 bucket stats for the Verbose podcast. Each day it fetches the previous day's logfiles for the podcast bucket, isolates those log entries that are relevant for podcast downloads, then saves them in a database. On the front end it provides simple stats visually to show ongoing activity over period, including downloads, locations, regular downloaders and downloading agents.

### TODO

 * Use the Amazon request id to make sure we don't double up in the database at any point
 * Make the date range work
 * Create first stab at front end page with simple results!
 * Apply IP lookup to store country/city data based on IP
 * Mark locations on map
 * Add a way to tell it to read arbitrary dates to fill the db
 * Deploy to PaaS of some sort
 * Read in all the things
 * Profit!!!

### Anatomy of an AWS S3 log entry

Reference: [http://docs.aws.amazon.com/AmazonS3/latest/dev/LogFormat.html]

Here's what a podcast entry looks like

```
8021ec09afa691bca04f6a84f42ef094f8c2aa698d740694b71a7f8f6e149877 verbose-ireland  37.228.196.48 - 6472D7A57DB1174F REST.GET.OBJECT 01_TheVerbosePodcast_-_Episode01.mp3 "GET /verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3 HTTP/1.1" 206 - 50984143 50984143 18523 54 "https://s3-eu-west-1.amazonaws.com/verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.64 Safari/537.31" -
```

and this is it split up

```
bucket owner    : 8021ec09afa691bca04f6a84f42ef094f8c2aa698d740694b71a7f8f6e149877 
bucket          : verbose-ireland 
time            : [23/May/2013:09:43:50 +0000] 
remote ip       : 37.228.196.48 
requester       : - 
request id      : 6472D7A57DB1174F 
operation       : REST.GET.OBJECT 
key             : 01_TheVerbosePodcast_-_Episode01.mp3 
request uri     : "GET /verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3 HTTP/1.1" 
http status     : 206 
error code      : - 
bytes sent      : 50984143 
object size     : 50984143 
total time (ms) : 18523 
turnaround time : 54 
referrer        : "https://s3-eu-west-1.amazonaws.com/verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3" 
user agent      : "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.64 Safari/537.31" 
version id      : -
```
