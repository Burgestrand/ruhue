# Ruhue

So far, mere documentations of my findings when sniffing the Hue.

## Mailing list

There is a mailing list, dedicated to discussions and questions about hacking the
Philips Hue and related protocols.

- Web interface: <https://groups.google.com/d/forum/hue-hackers>
- E-mail address: <hue-hackers@googlegroups.com>

## Resources
Information about Hue hacking resources, and my personal experiences with them.

### [Hack the Hue](http://rsmck.co.uk/hue)

My initial attempts at replicating his findings proved unsuccessful. However,
I was given an example JSON payload via e-mail, and it turns out the username
has some kind of length restriction.

- “adamgamble” is accepted.
- “adamgam” is not accepted.

### [A Day with Philips Hue](http://www.nerdblog.com/2012/10/a-day-with-philips-hue.html?showComment=1352172383498)

Nothing to say here yet. Some new information in comparison to Hack the Hue,
but the API documentation is not as complete.

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

### Device discovery

Device discovery is done over [SSDP][]. An example of such discovery written
in Ruby can be found in `scripts/discovery.rb`.

[SSDP]: http://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol

### GET /description.xml

Appears to be a general description about the device. Presentation URL, as
well as icons, are reachable via GET.

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
be able to see a list of registered applications through `GET /api/<username>/config`
in the `whitelist` key. More information about that call and the return body below.

If you register multiple times, even if it is with the same parameters, the Hub will
register every successfull registration in the whitelist. I do not yet know how to
remove applications from the Hue.

#### Parameters

- username: numbers (0-9) and letters (a-z, A-Z), between 10 and 40 bytes in length (inclusive).
- devicetype: appears to accept any string, between 1 and 40 bytes in length (inclusive).

#### Responses

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

Failure. Given an invalid username (too short), and an empty devicetype. Error
type 7 is for invalid values, and the description contains a human readable
string of what is wrong.

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

A successful initial post, given a username of `burgestrand` and device type of
`macbook`.  As you can see, an error of type 101 means that the user needs to
press the link button on the Hue hub, in order for it to allow new registrations.

```json
[
  {
    "success":{
      "username":"burgestrand"
    }
  }
]
```

Same request as above example, but after the link button has been pressed. I am
currently unaware if there is a certain time this pairing needs to be done after
clicking the link button.

The username is used for subsequent API calls.

### GET /api/<username>/config

Retrieve device configuration.

#### Parameters

- <username>: the username you used for registering your application in `POST /api`.

#### Responses

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
