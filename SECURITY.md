# Security Policy

## Reporting a security issue

There is no private security contact for HTPL yet. Report security
issues by opening an issue on this repository, using the bug report
template and marking it clearly as a security issue in the title.

Please note: **the HTPL source code is not public yet**, so a report
cannot assume access to the source. Describe the issue in full —
what you did, what you expected, what happened instead — and paste
any `.htpl` code inline. Do not include credentials, tokens, or
private data in the report.

## What counts

- Signature verification bypass (a gadget install that accepts a
  bad or missing signature)
- Sandbox escape (evaluated code reaching a capability it was not
  granted)
- A hole in the install-time capability scan
- A crash, hang, or wrong output caused by crafted input

## Scope

HTPL v1.0.0. The registry dashboard and the static registry are
part of the project; the Playground and website are not live yet,
so reports about them should describe the built behaviour, not a
live deployment.
