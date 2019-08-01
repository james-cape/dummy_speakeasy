# README

This repo serves as a test repo for Speakeasy.

To have buildkite ready,
1. Get agent token from buildkite
2. cd into the dummy directory and enter `$buildkite-agent start --token 80e4bcf00...` to the terminal.

To fail a build on purpose, add an open parantheses in the top line of the Gemfile.lock:
1. Open this repo in a text editor
1. Go to Gemfile.lock
1. Add a "(" after GEM in the top line to make it "GEM("
1. `git add .`
1. `git commit -m "commit message"`
1. `git push heroku master`

To un-fail, repeat the steps above, but remove the open parantheses.
