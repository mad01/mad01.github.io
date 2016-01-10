---
layout: post
title: python protobuf over http
date: 2016-01-11
categories: protobuf python http
---

The point of this is a smal example on how you could use protobuf to send data over http. In this example i will be using falcon for the server and a command line tool as the client. The example will just be a simple ping/pong a message and a channel sent to the server that will return pong and the message and channel sent. 

lets first start with the structure of the files is like the following. all files used can be found on github see source in the end of the post.
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

build the proto python file. you will get py\_proto\_pb2.py which is the protobuf python class file that you now can use to build a proto client and server
{% highlight bash%}
$ protoc --python_out=. lib/py_proto.proto
{% endhighlight %}


Server api. The server used the generated protobuf python file to parse the message and to encode the response.
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


Server function made to run with gunicorn.
{% highlight python %}
#!/usr/bin/env python3
import falcon
from lib import server_api

api = falcon.API()
api.add_route('/api/ping', server_api.Ping())
{% endhighlight %}


Start the server by doing the following
{% highlight bash %}
$ gunicorn server:api
{% endhighlight %}


Client api. Like in the server we use the same python generated proto file. To encode the messame to binary, and read the response.
{% highlight python %}
#!/usr/bin/env python3
import requests
from . import py_proto_pb2 as proto

class Client(object):

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            "Content-Type": "application/x-protobuf",
            "Accept": "application/x-protobuf"
        })

    def pingId(self, ping):
        return proto.PingIdDTO.Value(ping)

    def build_url(self, urn):
        url = 'http://%s:8000/%s' % ('127.0.0.1', urn)
        return url

    def send_ping(self, msg='', channel='', pingId=''):
        url = self.build_url('api/ping')
        command = proto.PingCommand()
        command.ping.msg = str(msg)
        command.ping.channel = str(channel)
        command.ping.pingId = self.pingId(pingId)

        res = self.session.post(url, data=command.SerializeToString())
        cmd = proto.PingDocument()
        cmd.ParseFromString(res.content)
        return cmd
{% endhighlight %}


Client. Made as a command line tool to be able to just send some infor in and then print th response. You send PING which is id 1 and you should get back id 2 from the server
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


The example can be found here. [Source](https://github.com/mad01/examples/tree/master/protobuf)
