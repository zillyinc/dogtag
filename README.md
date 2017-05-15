Dogtag
======

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

To configure the connection to your Redis server simply set the `REDIS_URL` environment variable. By default it will connect to `redis://localhost:6379`.

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
Dogtag.generate_id data_type, count
```

*Note: The available data type ID numbers are current 0 - 255.*

Related Projects
----------------
- __[dogtag-web](https://github.com/zillyinc/dogtag-web)__ - Web API for dogtag

TODO
----
- Support multiple Redis servers
- Use Redis `SCRIPT LOAD` for running the Lua script
