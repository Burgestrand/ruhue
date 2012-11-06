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
