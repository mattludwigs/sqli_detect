# SQLiDetect

This is a proof of concept using the Elixir to detect SQLi attacks via LiveView
websocket. This should not be used in any production systems.

## Motivation

Security detection for HTTP requests at the Web Application Firewall (WAF) is
well understood and supported by major cloud providers. They may use the
[OWASP coreruleset](https://github.com/coreruleset/coreruleset) to regex on
incoming payloads to detect malicious payloads.

Unfortunately, after a websocket connection is opened, the WAF does not see
the messages sent between the client and server. This prevents us from using
these nice detection tools for our websockets.

My motivation for this experiment is clear: I want the same protections and
tooling for websocket security as we have for HTTP security.

I think this important to grow the safety of LiveView applications.

Also, I thought it would be fun to explore this problem space with Elixir's
ML family of libraries - so admittedly I am scratching an ich for fun.

## Goal of this repo

The goal of this repo is to provide experimentation with some ideas around how
we might build security tooling around websocket messages for Elixir LiveView
applications. This repo can answer key questions that may lead to a generic
solution to this problem that we can share as a community.

## How to use

1. Ensure you have Elixir and Erlang installed
1. Clone repo
1. Run `mix setup`
1. Run `iex -S mix phx.server`
1. Navigate to http://locahost:4000/overview
1. Test both SQLi and normal input

## High level implementation

This works by providing an Nx serving of a [DistilBERT model trained for SQLi detection](https://huggingface.co/cybersectony/sql-injection-attack-detection-distilbert).
Secondly, we have a LiveView hook (not a JS hook, but a server side
hook) that is ran for every handle event and checks the user params for SQLi.
In this example we configure this in `live_session`'s `on_mount` option, so that
any LiveView added to that live session will get SQLi detections out of the box.

This is a complete experiment and not all implementation details are going to
be ideal. I'd like a way to improve these and I am open to collaboration.
