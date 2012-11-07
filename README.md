# Ruhue

So far, mere documentations of my findings when sniffing the Hue.

There is a mailing list, dedicated to discussions and questions about hacking the
Philips Hue and related protocols.

- Mailing list web interface: <https://groups.google.com/d/forum/hue-hackers>
- Mailing list e-mail address: <hue-hackers@googlegroups.com>

Other link resources:
- [Hack the Hue](http://rsmck.co.uk/hue)
- [A Day with Philips Hue](http://www.nerdblog.com/2012/10/a-day-with-philips-hue.html?showComment=1352172383498)

## Console

There is a console script in this repository, written by @Burgestrand as the
documentation effort travels further. It is written in Ruby, and only supports
Ruby 1.9.x and newer. You may start the console with the following:

1. Install bundler: `gem install bundler`
2. Install console script dependencies: `bundle install`
3. Run the console script: `ruby console.rb`

You’ll be dropped into a pry prompt (similar to IRB), with access to the following
local variables:

- hue — a Hue instance, documented in `lib/hue.rb`
- client — a Hue::Client, documented in `lib/hue/client.rb`

Once the documentation adventure starts slowing down, the scripts will be
turned into a ruby gem and tested with rspec.

## API

To use the Hue hub API you’ll first need to register an application. This is
done with a `POST /api`, together with a payload (described further down).
Before you do this you’ll need to press the link button on your Hue hub, so
that the Hub will be ready to register a new application.

After registering your application you’ll use the username chosen for all API
calls in the future. One effect of this is that the Hue hub will track when
the last API call by a specific device has been made.

Notes about the documentation:

1. Numbers in sequence (1234…cdef) are in base 16.
2. Numbers starting with 10… are in base 10.
3. POST data is meant to be encoded as JSON objects unless otherwise stated.

Formatting rules:

- Every API call has it’s own third-level header. Parameters in the URL
  are to be called out with `inline code markup`, e.g. GET /api/`username`.
- An optional description for the API call is written as paragraphs under
  the API call header.
- For GET and DELETE calls, an example JSON response must follow. Multiple
  response examples are allowed if different responses are available.
- For POST and PUT calls, parameters must be listed and explained under a
  fourth-level header named "Parameters".
- For POST and PUT calls, an example JSON response must be supplied under
  a fourth-level header named "Responses". Multiple response examples are
  allowed if different responses are available.
- Each example response should be preceded by an explanatory paragraph,
  for additional details about the call and what the response describes.
- Example JSON payloads should be formatted with <http://jsonformatter.curiousconcept.com/>, at two
  space indentation.

### Device discovery

Device discovery is done over [SSDP][]. An example of such discovery written
in Ruby can be found in `lib/hub.rb` in the `Hub.discovery` method.

[SSDP]: http://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol

### GET /description.xml

Appears to be a general description about the device. Presentation URL, as
well as icons, are reachable via GET requests.

```xml
<?xml version="1.0"?>
<root xmlns="urn:schemas-upnp-org:device-1-0">
  <specVersion>
    <major>1</major>
    <minor>0</minor>
  </specVersion>
  <URLBase>http://192.168.0.21:80/</URLBase>
  <device>
    <deviceType>urn:schemas-upnp-org:device:Basic:1</deviceType>
    <friendlyName>Philips hue (192.168.0.21)</friendlyName>
    <manufacturer>Royal Philips Electronics</manufacturer>
    <manufacturerURL>http://www.philips.com</manufacturerURL>
    <modelDescription>Philips hue Personal Wireless Lighting</modelDescription>
    <modelName>Philips hue bridge 2012</modelName>
    <modelNumber>1000000000000</modelNumber>
    <modelURL>http://www.meethue.com</modelURL>
    <serialNumber>93eadbeef13</serialNumber>
    <UDN>uuid:01234567-89ab-cdef-0123-456789abcdef</UDN>
    <serviceList>
      <service>
        <serviceType>(null)</serviceType>
        <serviceId>(null)</serviceId>
        <controlURL>(null)</controlURL>
        <eventSubURL>(null)</eventSubURL>
        <SCPDURL>(null)</SCPDURL>
      </service>
    </serviceList>
    <presentationURL>index.html</presentationURL>
    <iconList>
      <icon>
        <mimetype>image/png</mimetype>
        <height>48</height>
        <width>48</width>
        <depth>24</depth>
        <url>hue_logo_0.png</url>
      </icon>
      <icon>
        <mimetype>image/png</mimetype>
        <height>120</height>
        <width>120</width>
        <depth>24</depth>
        <url>hue_logo_3.png</url>
      </icon>
    </iconList>
  </device>
</root>
```

### POST /api

Initial request, used to register an application with the Hue hub. Once registered,
the username used is like an API key.

After successfully registering an application, the Hub hub will remember it. You’ll
be able to see a list of registered applications through `GET /api/username/config`
in the `config/whitelist` key. More information about that call and the return body
below.

If you register multiple times, even if it is with the same parameters, the Hub will
register every successfull registration in the whitelist. You can delete registered
users from the whitelist with `DELETE /api/username/config/whitelist/username`.

#### Parameters

- username: numbers (0-9) and letters (a-z, A-Z), between 10 and 40 bytes in length (inclusive).
- devicetype: appears to accept any string, between 1 and 40 bytes in length (inclusive).

#### Responses

Failure. Given an invalid username (too short), and an empty devicetype. Error
type 7 is for invalid values, and the description contains a human readable
string of what is wrong.

```json
[
  {
    "error":{
      "type":7,
      "address":"/username",
      "description":"invalid value, burges, for parameter, username"
    }
  },
  {
    "error":{
      "type":2,
      "address":"/",
      "description":"body contains invalid json"
    }
  }
]
```

To generate an API key on the bridge do a POST:

### POST /api
```json
{"username": "yourApp", "devicetype": "yourAppName"}
```

A successful initial post, given a username of `burgestrand` and device type of
`macbook`.  As you can see, an error of type 101 means that the user needs to
press the link button on the Hue hub, in order for it to allow new registrations.

```json
[
  {
    "error":{
      "type":101,
      "address":"",
      "description":"link button not pressed"
    }
  }
]
```

Same request as above example, but after the link button has been pressed. I am
currently unaware if there is a certain time this pairing needs to be done after
clicking the link button.

The username is used for subsequent API calls.

```json
[
  {
    "success":{
      "username":"burgestrand"
    }
  }
]
```

### GET /api/`username`

Username is the username you used for registering your application in `POST /api` call.
This API call will return a hash, containing information about hub configuration (same
as `GET /api/username/config`), the lights, groups (unsure of what it is about), and
schedules (commands to be executed at a given timestamp).

```json
{
  "lights":{
    "1":{
      "state":{
        "on":true,
        "bri":240,
        "hue":15331,
        "sat":121,
        "xy":[
          0.4448,
          0.4066
        ],
        "ct":343,
        "alert":"none",
        "effect":"none",
        "colormode":"ct",
        "reachable":true
      },
      "type":"Extended color light",
      "name":"TV Vänster",
      "modelid":"LCT001",
      "swversion":"65003148",
      "pointsymbol":{
        "1":"none",
        "2":"none",
        "3":"none",
        "4":"none",
        "5":"none",
        "6":"none",
        "7":"none",
        "8":"none"
      }
    },
    "2":{
      "state":{
        "on":true,
        "bri":240,
        "hue":15331,
        "sat":121,
        "xy":[
          0.4448,
          0.4066
        ],
        "ct":343,
        "alert":"none",
        "effect":"none",
        "colormode":"ct",
        "reachable":true
      },
      "type":"Extended color light",
      "name":"TV Höger",
      "modelid":"LCT001",
      "swversion":"65003148",
      "pointsymbol":{
        "1":"none",
        "2":"none",
        "3":"none",
        "4":"none",
        "5":"none",
        "6":"none",
        "7":"none",
        "8":"none"
      }
    },
    "3":{
      "state":{
        "on":true,
        "bri":240,
        "hue":15331,
        "sat":121,
        "xy":[
          0.4448,
          0.4066
        ],
        "ct":343,
        "alert":"none",
        "effect":"none",
        "colormode":"ct",
        "reachable":true
      },
      "type":"Extended color light",
      "name":"Skrivbord",
      "modelid":"LCT001",
      "swversion":"65003148",
      "pointsymbol":{
        "1":"none",
        "2":"none",
        "3":"none",
        "4":"none",
        "5":"none",
        "6":"none",
        "7":"none",
        "8":"none"
      }
    }
  },
  "groups":{

  },
  "config":{
    "name":"Lumm",
    "mac":"00:00:00:00:7b:be",
    "dhcp":true,
    "ipaddress":"192.168.0.21",
    "netmask":"255.255.255.0",
    "gateway":"192.168.0.1",
    "proxyaddress":" ",
    "proxyport":0,
    "UTC":"2012-11-06T21:57:59",
    "whitelist":{
      "24e04807fe143caeb52b4ccb305635f8":{
        "last use date":"2012-11-06T20:43:34",
        "create date":"1970-01-01T00:00:45",
        "name":"Kim Burgestrand’s iPhone"
      },
      "9874172fdb7caf6f62cc9a935276229f":{
        "last use date":"2012-11-06T19:20:35",
        "create date":"2012-11-05T20:41:24",
        "name":"iPhone"
      },
      "burgestrand":{
        "last use date":"2012-11-06T21:57:59",
        "create date":"2012-11-06T21:29:57",
        "name":"macbook"
      },
    },
    "swversion":"01003542",
    "swupdate":{
      "updatestate":0,
      "url":"",
      "text":"",
      "notify":false
    },
    "linkbutton":false,
    "portalservices":true
  },
  "schedules":{
    "1":{
      "name":"Frukost on f 012373           ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/3/state",
        "body":{
          "bri":1,
          "xy":[
            0.52594,
            0.43074
          ],
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T04:41:00"
    },
    "2":{
      "name":"Frukost on 103811             ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/3/state",
        "body":{
          "bri":253,
          "transitiontime":5400,
          "xy":[
            0.52594,
            0.43074
          ],
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T04:41:02"
    },
    "3":{
      "name":"Frukost on f 201200           ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/1/state",
        "body":{
          "bri":1,
          "xy":[
            0.58985,
            0.37833
          ],
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T04:41:00"
    },
    "4":{
      "name":"Go go go on 190458            ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/1/state",
        "body":{
          "bri":55,
          "ct":156,
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T05:20:02"
    },
    "5":{
      "name":"Go go go on 318280            ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/2/state",
        "body":{
          "bri":55,
          "ct":156,
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T05:20:02"
    },
    "6":{
      "name":"Go go go on 413685            ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/3/state",
        "body":{
          "bri":55,
          "ct":156,
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T05:20:02"
    },
    "7":{
      "name":"Go go go off 530448           ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/1/state",
        "body":{
          "on":false
        },
        "method":"PUT"
      },
      "time":"2012-11-07T05:26:00"
    },
    "8":{
      "name":"Go go go off 624596           ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/2/state",
        "body":{
          "on":false
        },
        "method":"PUT"
      },
      "time":"2012-11-07T05:26:00"
    },
    "9":{
      "name":"Go go go off 719690           ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/3/state",
        "body":{
          "on":false
        },
        "method":"PUT"
      },
      "time":"2012-11-07T05:26:00"
    },
    "10":{
      "name":"Frukost on 295760             ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/1/state",
        "body":{
          "bri":254,
          "transitiontime":5400,
          "xy":[
            0.58985,
            0.37833
          ],
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T04:41:02"
    },
    "11":{
      "name":"Frukost on f 388741           ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/2/state",
        "body":{
          "bri":1,
          "xy":[
            0.58985,
            0.37833
          ],
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T04:41:00"
    },
    "12":{
      "name":"Frukost on 483284             ",
      "description":" ",
      "command":{
        "address":"/api/24e04807fe143caeb52b4ccb305635f8/lights/2/state",
        "body":{
          "bri":254,
          "transitiontime":5400,
          "xy":[
            0.58985,
            0.37833
          ],
          "on":true
        },
        "method":"PUT"
      },
      "time":"2012-11-07T04:41:02"
    }
  }
}
```

### GET /api/`username`/config

Retrieves Hue hub configuration information. Can also be retrieved from `GET /api/username`.

```json
{
  "name":"Lumm",
  "mac":"00:00:00:00:7b:be",
  "dhcp":true,
  "ipaddress":"192.168.0.21",
  "netmask":"255.255.255.0",
  "gateway":"192.168.0.1",
  "proxyaddress":" ",
  "proxyport":0,
  "UTC":"2012-11-06T21:35:35",
  "whitelist":{
    "24e04807fe143caeb52b4ccb305635f8":{
      "last use date":"2012-11-06T20:43:34",
      "create date":"1970-01-01T00:00:45",
      "name":"Kim Burgestrand’s iPhone"
    },
    "burgestrand":{
      "last use date":"2012-11-05T20:39:41",
      "create date":"2012-11-06T21:31:10",
      "name":"macbook"
    }
  },
  "swversion":"01003542",
  "swupdate":{
    "updatestate":0,
    "url":"",
    "text":"",
    "notify":false
  },
  "linkbutton":false,
  "portalservices":true
}
```

It is also possible to get parts of other information by using one of the following GET requests:

### GET /api/`username`/lights/

### GET /api/`username`/groups/

### GET /api/`username`/schedules/

As far as we can tell at the moment, the partial info GET request for lights is the only one showing different info than the whole info request.



### PUT http://192.168.0.21/api/yourApp/config/
```json
{"name": "New Name"}
```

This will change the name option on your bridge

it will return:
```json
{"success":{"/config/name":"New Name"}}
```


### DELETE /api/`username`/config/whitelist/`username`

Removes a username from the whitelist of registered applications.

```json
[
  {
    "success":"/config/whitelist/burgestrand deleted"
  }
]
```

Regarding changing settings of your attached lights; currently it looks like that it isn't possible to change multiple lights with one request.


### PUT http://192.168.0.21/api/yourApp/lights/1/state/
```json
{"on": false}
```
This will turn a light off. It is not the same as bri: 0!!

It will return:
```json
[{"success":{"/lights/1/state/on":false}}]
```
