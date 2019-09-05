#!/usr/bin/env bash

(
  cd backend
  cf7 push
)

(
  cd frontend
  cf7 push
)

(
  cf add-network-policy hackney-frontend --destination-app hackney-backend
)
