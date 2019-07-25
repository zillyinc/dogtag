Dogtag [![Code Climate](https://codeclimate.com/repos/5942bc55a2d69c025b00037d/badges/9f08a12606fdc4e23360/gpa.svg)](https://codeclimate.com/repos/5942bc55a2d69c025b00037d/feed) [![Build Status](https://travis-ci.com/zillyinc/dogtag.svg?token=zLzTcsQJDEyJnTYpWzNq&branch=master)](https://travis-ci.com/zillyinc/dogtag)
============

A Redis-powered Ruby client for generating unique IDs with Redis for use in distributed systems. Based heavily off of [Icicle](https://github.com/intenthq/icicle/) and [Twitter Snowflake](https://github.com/intenthq/icicle/)

Requirements
------------
- [Ruby](https://www.ruby-lang.org)
- [Redis](https://redis.io/)

Installation
------------

Simply add `gem 'dogtag'` to your `Gemfile` and run `bundle`

Configuration
-------------

To configure the connection to your Redis server simply set a `DOGTAG_REDIS_URL` or `REDIS_URL` environment variable. Dogtag will first look for the `DOGTAG_REDIS_URL`, then `REDIS_URL`. If neither are found it will default to `redis://127.0.01:6379`.

To set the range of logical shard IDs this server should manage, run the command below replacing the number range with a range of numbers, of which none can be shared with another Redis server. If a logical shard ID is shared a separate Redis instance, you may get ID collisions.

```shell
bundle exec ruby -e 'require "dogtag"; Dogtag.logical_shard_id_range = 0..31'
```

*Note: The available shard ID numbers are current 0 - 31.*

Usage
-------

```ruby
data_type = 0
Dogtag.generate_id data_type
```

```ruby
data_type = 42
count = 100
Dogtag.generate_ids data_type, count
```

```ruby
id_number = Dogtag.generate_id 42
id = Dogtag::Id.new(id_number)
id.data_type #=> 42
id.sequence #=> 1
id.logical_shard_id #=> 12
id.custom_timestamp # time since custom epoch
id.timestamp.to_i #=> 28146773761 # Unix timestamp
id.timestamp.to_time # Ruby Time object
id.timestamp.epoch #=> 1483228800000
```

*Note: The available data type ID numbers are current 0 - 255.*

A list of existing IDs types and numbers can be found: https://github.com/zillyinc/zilly-backend/blob/master/config/initializers/tellus_dogtag.rb

Gotchas
-------

- If you are going to store the ID in the database you'll need to make sure it can store 64 bit integers. In [Rails](http://rubyonrails.org/) this means using `integer` `limit: 8` in your migrations.
- Be careful of using Dogtag IDs with JavaScript, since it [doesn't handle 64 bit integers well](http://stackoverflow.com/questions/9643626/javascript-cant-handle-64-bit-integers-can-it). You'll probably want to work with them as strings.

Related Projects
----------------
- __[dogtag-web](https://github.com/zillyinc/dogtag-web)__ - Web API for dogtag

Testing
-------

Simply spin up a Redis server and run `bundle exec rspec`.

TODO
----
- Support multiple Redis servers
