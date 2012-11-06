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

1. Numbers in sequence (1234…cdef) are in base 16.
2. Numbers starting with 10… are in base 10.

### Device discovery

Device discovery is done over [SSDP][]. An example of such discovery written
in Ruby can be found in `scripts/discovery.rb`.

[SSDP]: http://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol

### GET http://192.168.0.21/description.xml

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

To generate a API key on the bridge, do a POST:

### POST http://192.168.0.21/api
```json
{"username": "yourApp", "devicetype": "yourAppName"}
```

it will return your API key (the username is your API key):
```json
{"success":{"username":"yourApp"}}
```


After receiving the API key you can do a GET request to the bridge to get all the information available:

### GET http://192.168.0.21/api/yourApp/

this will return something like:
```json
{
    "lights": {
        "1": {
            "state": {
                "on": false,
                "bri": 5,
                "hue": 14922,
                "sat": 144,
                "xy": [0.4595, 0.4105],
                "ct": 369,
                "alert": "none",
                "effect": "none",
                "colormode": "ct",
                "reachable": true
            },
            "type": "Extended color light",
            "name": "Lamp 1",
            "modelid": "LCT001",
            "swversion": "65003148",
            "pointsymbol": {
                "1": "none",
                "2": "none",
                "3": "none",
                "4": "none",
                "5": "none",
                "6": "none",
                "7": "none",
                "8": "none"
            }
        }
    },
    "groups": {},
    "config": {
        "name": "Philips hue",
        "mac": "{BRIDGE_MAC_ADDR}",
        "dhcp": false,
        "ipaddress": "192.168.0.21",
        "netmask": "255.255.255.0",
        "gateway": "192.168.0.21",
        "proxyaddress": " ",
        "proxyport": 0,
        "UTC": "2012-11-06T19:54:47",
        "whitelist": {
            "yourApp": {
                "last use date": "2012-11-06T19:54:47",
                "create date": "2012-11-06T19:29:36",
                "name": "yourAppName"
            }
        },
        "swversion": "01003542",
        "swupdate": {
            "updatestate": 0,
            "url": "",
            "text": "",
            "notify": false
        },
        "linkbutton": false,
        "portalservices": false
    },
    "schedules": {}
}
```

It is also possible to get parts of the information by using one of the following GET requests:

### GET http://192.168.0.21/api/yourApp/lights/

### GET http://192.168.0.21/api/yourApp/config/

### GET http://192.168.0.21/api/yourApp/groups/

### GET http://192.168.0.21/api/yourApp/schedules/


To change an option on your bridge you need to do a PUT request (NOT POST):

### PUT http://192.168.0.21/api/yourApp/config/
```json
{"name": "New Name"}
```

this will return:
```json
{"success":{"/config/name":"New Name"}}
```

Regarding changing settings of your attached lights; currently it looks like that it isn't possible to change 
multiple lights with one request.


To turn a light off, you can use the following PUT request:

### PUT http://192.168.0.21/api/yourApp/lights/1/state/
```json
{"on": false}
```

this will return:
```json
[{"success":{"/lights/1/state/on":false}}]
```