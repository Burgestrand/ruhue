# Ruhue

So far, mere documentations of my findings when sniffing the Hue.

Additional resources I’ve found about the Hue so far:

- Parts of the Hue API: http://rsmck.co.uk/hue — looks promising, but I cannot
  get the initial application registration to return anything else other than
  errors about my username and device type. I’ll have to delve deeper into this.

## Mailing list

There is a mailing list, dedicated to discussions and questions about hacking the
Philips Hue and related protocols.

- Web interface: <https://groups.google.com/d/forum/hue-hackers>
- E-mail address: <hue-hackers@googlegroups.com>

<iframe id="forum_embed" src="javascript:void(0)" scrolling="no" frameborder="0" width="900" height="700">
</iframe>
<script type="text/javascript">
  document.getElementById('forum_embed').src =
     'https://groups.google.com/forum/embed/?place=forum/hue-hackers'
     + '&showsearch=false&showtabs=false&hideforumtitle=true&hidesubject=true'
     + '&parenturl=' + encodeURIComponent(window.location.href);
</script>

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
