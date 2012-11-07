## POST /api

Register an application with the Hue hub. All API calls to the Hue hub require a
registered username as part of the URL.

After application registration, application details will be remembered by the Hub.
The Hub also keeps track of last access, as can be seen in GET [[/api/:username/config]],
part of the `whitelist` response property.

If you register multiple times, even if it is with the same parameters, the Hub will
register every successfull registration in the whitelist. You can delete registered
users from the whitelist with DELETE [[/api/:username/config/whitelist/:username]].

### Parameters

- username: numbers (0-9) and letters (a-z, A-Z), between 10 and 40 bytes in length (inclusive).
- devicetype: appears to accept any string, between 1 and 40 bytes in length (inclusive).

```json
{
  "username":"burgestrand",
  "devicetype":"any random thing"
}
```

### Responses

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