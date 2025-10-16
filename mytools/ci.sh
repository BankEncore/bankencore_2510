#!/bin/bash
bundle exec rubocop --fail-level W
rails zeitwerk:check