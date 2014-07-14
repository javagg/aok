#!/bin/bash -e

source `dirname $0`/setup.bash

# First reset the user db:
{
  api-get /Users/RESET/
  is "$(api-status)" 200 '/Users/RESET works'

  api-get /Groups/RESET/
  is "$(api-status)" 200 '/Groups/RESET works'

  api-get /Users
  is "$(api-output-get '/totalResults')" 0 \
    'Verify no users after RESET'

  api-get /Groups
  is "$(api-output-get '/totalResults')" 0 \
    'Verify no groups after RESET'
}

# Test adding a user:
{
  api-post /Users "$User_ingy"
  is "$(api-status)" 201 \
    'Create user worked'

  api-get /Users
  is "$(api-output-get '/totalResults')" 1 \
    'Total users is 1'

  is "$(api-output-get '/resources/0/userName')" ingy \
    'userName set correctly'
}

# Test adding a group:
{
  api-post /Groups "$Group_admin"
  is "$(api-status)" 201 \
    'Create group worked'

  api-get /Groups
  is "$(api-output-get '/totalResults')" 1 \
    'Total groups is 1'

  is "$(api-output-get '/resources/0/displayName')" aok.admin \
    'displayName set correctly'
}

done_testing 10
