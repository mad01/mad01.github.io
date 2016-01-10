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
{% endhighlight %}


The example can be found here. [Source](https://github.com/mad01/examples)
