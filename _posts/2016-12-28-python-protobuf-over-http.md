---
layout: post
title: python protobuf over http
date: 2016-01-11
categories: protobuf python http
---

The point of this is a smal example on how you could get started with a client and server in python using protobuf to send data over http with some error handeling.

lets first strat with the structure of the files is like the following.
{% highlight bash %}
protobuf
├── client.py
├── lib
│   ├── __init__.py
│   ├── client_api.py
│   ├── py_proto.proto
│   ├── py_proto_pb2.py
│   └── server_api.py
├── requirements.txt
├── server.py
└── tests
    └── test_proto.py
{% endhighlight %}


to get started we need a protobuf file that sets the format of messages that should be used.
{% highlight bash %}
package api;

enum PingIdDTO {
    PING = 1;
    PONG = 2;
}

message PingDTO {
    required string msg = 1;
    required string channel = 2;
    required PingIdDTO pingId = 3;
}

message PingCommand {
    required PingDTO ping = 1;
}

message PingDocument {
    required PingDTO ping = 1;
}
{% endhighlight %}

build the proto python file. you will get py_proto_pb2.py which is the protobuf python class file that you now can use to build a proto client and server
{% highlight bash%}
$ protoc --python_out=. lib/py_proto.proto
{% endhighlight %}



{% highlight python %}
#!/usr/bin/env python3
import falcon
from . import py_proto_pb2 as proto

def proto_http_type():
    return 'application/x-protobuf'

class Ping(object):

    def __init__(self):
        self.proto = proto

    def on_post(self, req, resp):
            command = proto.PingCommand()
            command.ParseFromString(req.stream.read())

            cmd = proto.PingDocument()
            cmd.ping.msg = command.ping.msg
            cmd.ping.channel = command.ping.channel
            cmd.ping.pingId = proto.PONG

            print('msg: %s' % command.ping.msg)
            print('channel: %s' % command.ping.channel)

            resp.content_type = proto_http_type()
            resp.status = falcon.HTTP_201
            resp.data = cmd.SerializeToString()
{% endhighlight %}

server
{% highlight python %}
#!/usr/bin/env python3
import falcon
from lib import server_api


api = falcon.API()
api.add_route('/api/ping', server_api.Ping())
{% endhighlight %}


tests
{% highlight python %}
#!/usr/bin/env python3
import unittest
from lib import client_api


class TestClient(unittest.TestCase):

    @classmethod
    def setUpClass(self):
        self.api = client_api.Client()

    def test_ping(self):
        msg = 'hello'
        channel = 'foo'
        cmd = self.api.send_ping(
            msg=msg,
            channel=channel,
            pingId='PING'
            )
        self.assertEqual(cmd.ping.pingId, self.api.pingId('PONG'))
        self.assertEqual(cmd.ping.msg, msg)
        self.assertEqual(cmd.ping.channel, channel)

if __name__ == '__main__':
    unittest.main()
{% endhighlight %}


client
{% highlight python %}
#!/usr/bin/env python3
import argparse
from lib import client_api

def call(msg='', channel=''):
    api = client_api.Client()
    cmd = api.send_ping(
        msg=msg,
        channel=channel,
        pingId='PING'
        )

    print('Response: %s' % api.pingId(cmd.ping.pingId))
    print('message sent: %s' % cmd.ping.msg)
    print('to channel: %s' % cmd.ping.channel)

def main():
    description = 'command line tool send messages to a channel'
    parser = argparse.ArgumentParser(description)
    parser.add_argument('-m', '--message', required=True)
    parser.add_argument('-c', '--channel', required=True)
    args = parser.parse_args()
    call(
        msg=args.message,
        channel=args.channel
        )

if __name__ == '__main__':
    main()
{% endhighlight %}

{% highlight bash %}
$ gunicorn server:api
{% endhighlight %}


The example can be found here. [Source](https://github.com/mad01/examples/tree/proto/protobuf)
