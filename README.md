# Coposition

[![Build Status](https://travis-ci.org/earlymarket/Coposition.svg?branch=master)](https://travis-ci.org/earlymarket/Coposition)
[![Code Climate](https://codeclimate.com/github/earlymarket/CoPosition/badges/gpa.svg)](https://codeclimate.com/github/earlymarket/CoPosition)
[![Test Coverage](https://codeclimate.com/github/earlymarket/CoPosition/badges/coverage.svg)](https://codeclimate.com/github/earlymarket/CoPosition/coverage)

## What's it all about?

### For users
You start using an app that requires your location, let's call it LifeInvader.

LifeInvader will immediately start tracking your location.

But, if LifeInvader used Coposition, you'd have to specify which of your devices it can see, and how much location data it has access to.

Keeping your data yours.


### For the developers
A very easy to use HTTP REST API, giving you some cool location-aware data.

Instant trust from your users.

Open source. If you see something you think could be improved, improve it!

--------
# Developer local setup

Add the following routes to your /etc/hosts

127.0.0.1    api.coposition-dev.com

127.0.0.1    coposition-dev.com

`bundle`

`rake db:create && rake db:migrate && rake db:seed`

## Example API usage

Create a user with the username `testuser`.

Create a developer.

Note the API key found on the developer dashboard.

### Create a device

To start posting a checkin, you need to tell us which device you're posting to.
This is determined by the UUID of the device.
If you're creating a new device, all you need to do is request a new UUID

`GET http://api.coposition-dev.com/uuid`

Headers: `X-API-KEY: YourApiKey`

### Posting a checkin

`POST http://api.coposition-dev.com/checkins`

Headers: `X-API-KEY: YourApiKey, X-UUID: YourDeviceUUID`

With the payload:
```
{
  "lat":"51.588330",
  "lng":"-0.513069"
}
```

If you then go to http://coposition-dev.com/users/testuser/devices > Add a device, enter the UUID, the device will be bound to your account with the check-in you created.

### Asking for approval

`POST http://api.coposition-dev.com/users/testuser/approvals`

Headers: `X-API-KEY: YourApiKey`

If you go to the user dashboard, you'll now see an approval request from the company you created.

Approving this allows the company to have access to that user's location data of all devices (by default).

### Getting the device information

`GET http://api.coposition-dev.com/users/testuser/devices`

Headers: `X-API-KEY: YourApiKey`

Returns an index of devices.

### Getting user check-ins

`GET http://api.coposition-dev.com/users/testuser/checkins`

Headers: `X-API-KEY: YourApiKey`

Returns an index of check-ins belonging to the testuser.

--------

### License
Copyright 2016 Earlymarket LLP
