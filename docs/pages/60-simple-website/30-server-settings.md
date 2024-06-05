# Override server settings

The default server settings are defined in the role and can be overridden:


## Security headers

The default security cannot be changed for the web site only, they are displayed here as
information:

```yml
nginx_sec_headers:
  - id: Strict-Transport-Security
    value: max-age=31536000
  - id: X-Content-Type-Options
    value: nosniff
  - id: Referrer-Policy
    value: same-origin
  - id: X-Frame-Options
    value: sameorigin
```


## Content Security Policies

The default content security policies are defined like this:

```yml
csp_default:
  default: "'self'"
  list:
    - id: default-src
      value: "https: 'self'"
    - id: script-src
      value: "https: 'self'"
    - id: img-src
      value: "https: 'self'"
    - id: style-src
      value: "https: 'self' data:"
    - id: media-src
      value: "https: 'self'"
    - id: font-src
      value: "https: 'self'"
    - id: base-uri
      value: "https: 'self'"
    - id: frame-src
    - id: object-src
    - id: connect-src
```

Here an example on how to override them:

```yml
website:
  […]
  csp:
    - id: default-src
      value: "https: 'self'"
    - id: script-src
      value: "https: 'self'"
    - id: img-src
      value: "https: 'self'"
    - id: style-src
      value: "https: 'self' data:"
    - id: media-src
      value: "https: 'self'"
    - id: base-uri
      value: "https: 'self'"
```


## Features policies

The default features policies are defined like this:

```yml
# See https://github.com/w3c/webappsec-feature-policy
# Set to 'none' by default
fp_default:
  default: "'none'"
  list:
    - id: geolocation
    - id: midi
    - id: notifications
    - id: push
    - id: sync-xhr
    - id: microphone
    - id: camera
    - id: magnetometer
    - id: gyroscope
    - id: speaker
    - id: vibrate
    - id: fullscreen
    - id: payment
```


Here an example on how to override them:

```yml
website:
  […]
  fp:
    - id: notifications
    - id: push
    - id: sync-xhr
    - id: magnetometer
    - id: speaker
```
