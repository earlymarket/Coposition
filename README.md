# Coposition
[![Build Status](https://travis-ci.org/earlymarket/CoPosition.svg?branch=master)](https://travis-ci.org/earlymarket/CoPosition)

## Setup

Add the following routes to your /etc/hosts

127.0.0.1    api.coposition-dev.com

127.0.0.1    coposition-dev.com

`bundle`

`rake db:create && rake db:migrate && rake db:seed`

## Example

Create a user with the username `testuser`.

Create a developer.

Note the API key.

### Posting a checkin

`POST http://api.coposition-dev.com/v1/checkins`
With the payload:
```
{
  "checkin": {
    "uuid":"1234567890",
    "lat":"51.588330",
    "lng":"-0.513069"
  }
}
```

If you then go to your Dashboard > Devices > Add a device, add the UUID `1234567890`, and the device will be bound to your account.


### Asking for approval

`POST http://api.coposition-dev.com/v1/users/testuser/approvals`
With `X-API-KEY: YourApiKey` passed as a header

If you go to the user dashboard, you'll now see an approval request from the company you created.

Approving this allows the company to have access to that user's location data of all devices (by default).


### Getting the device information

`GET http://api.coposition-dev.com/v1/users/testuser/devices/`
With `X-API-KEY: YourApiKey` passed as a header
Returns an index of devices.


--------

### License
Copyright 2015 Earlymarket LLP
