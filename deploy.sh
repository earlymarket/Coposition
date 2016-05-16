#!/bin/bash

heroku run rake db:migrate --app coposition
heroku run rake assets:clobber --app coposition
heroku run rake assets:precompile --app coposition
