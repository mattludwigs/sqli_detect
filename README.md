# SQLiDetect

This is a proof of concept using the Elixir to detect SQLi attacks via LiveView
websocket. This should not be used in any production systems.

## Motivation

Using WebSockets to power most of the application introduces new security
challenges. For instance, with typical HTTP requests, developers can use Web
Application Firewall (WAF) rules to block malicious traffic - major cloud
providers often offer built-in tooling to support this. But once a WebSocket
connection is established, the WAF can no longer inspect the messages being
sent. As a result, malicious users sending harmful payloads can bypass the
current security measures unnoticed.

In LiveView applications, we use functions like handle_event to process
untrusted user input, which means these callbacks carry the same risks as
handling an HTTP request. To address this, I quickly put together a proof of
concept that introduces a LiveView lifecycle hook. This hook intercepts
user-provided payloads and runs a detection model against the input to check
for SQL injection attempts.

My motivation for this experiment is clear: I want the same protections and
tooling for websocket security as we have for HTTP security.

I think this important to grow the safety of LiveView applications.

Also, I thought it would be fun to explore this problem space with Elixir's
ML family of libraries - so admittedly I am scratching an ich for fun.

Lastly, while this proof of concept currently has the code residing at the application level, I would prefer to move it away from requiring the application to have any knowledge of malicious payloads. Perhaps using a Phoenix LiveView socket proxy could be a solution? I'm not entirely certain about the best approach here, so I'm open to suggestions.

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

## Other resources

### OWASP coreruleset

The [OWASP coreruleset](https://github.com/coreruleset/coreruleset) is often
used in WAFs to detect malicious payloads.
