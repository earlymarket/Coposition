# Coposition
[![Build Status](https://travis-ci.org/earlymarket/CoPosition.svg?branch=master)](https://travis-ci.org/earlymarket/CoPosition)

## Example usage with demo app

### Setup Coposition
- Sign up on [coposition.com](http://coposition.com)
- Go to Dashboard > Devices > Add current device
- Enter a friendly name for your current device

### Use Whereforartthou
- Sign up on [whereforartthou.com](http://whereforartthou.com/)
- Enter some sign up information (Does not need to relate to Coposition in any way)
- Enter your Coposition username when prompted

Have a go at messing around with your Coposition permissions, and see how it affects WFAT

## Setup

Add the following routes to your /etc/hosts

127.0.0.1    api.coposition-dev.com

127.0.0.1    coposition-dev.com

`bundle`

`rake db:create && rake db:migrate && rake db:seed`

## Example
### Out of date as of 12/11/15, will be updated soon

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

`GET http://api.coposition-dev.com/v1/users/testuser/devices`
With `X-API-KEY: YourApiKey` passed as a header
Returns an index of devices.




--------

### License
Copyright 2015 Earlymarket LLP
