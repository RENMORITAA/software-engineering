#!/bin/bash
set -e

flutter pub get

exec "$@"
