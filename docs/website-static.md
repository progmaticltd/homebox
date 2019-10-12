# Static web site placeholder

A skeleton / placeholder is set to facilitate the publication of a small _static_ web site, without server side
processing.

The nginx server is configured with the most secure headers related to media and linked content, like JavaScript files,
stylesheets or images.

To public your web site, place it in a sub directory of the backup folder.

## Configuration

Configureyoure web site in `system.yml` file, for instance:

```yml
website:
  install: true
  locale: en_GB.UTF-8
```

## Steps for deployment

The first step is to copy the site content in backup/<domain-name>/website-simple/. The index page is called
`index.html`.

Then, run the playbook to deploy the web site:

```sh
cd install
ansible-playbook -v -i ../config/hosts.yml playbooks/website-simple.yml
```

## Defaults security settings

By default, nginx is configured to restrict the possible content served online, using specific headers:

- Content-Security-Policy
- Feature-Policy

The default settings are the safest but the most restrictive: they instruct the web browser to load content only from
your web site. You won't be able to load remote JavaScript or stylesheet files. However, it is possible to change this
behaviour, by customising the `website` variable. You can copy the default settings, and modify them according to your
needs:

```yml
####
csp_default:
  default: "'none'"
  list:
    - id: default-src
      value: "https: 'self'"
    - id: script-src
      value: "https: 'self'"
    - id: img-src
      value: "https: 'self'"
    - id: style-src
      value: "https: 'self'"
    - id: media-src
      value: "https: 'self'"
    - id: font-src
      value: "https: 'self'"
    - id: base-uri
      value: "https: 'self'"
    - id: frame-src
    - id: object-src
    - id: connect-src


### Features policy
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

For instance, to authorise loading external images, and XMLHttpRequests from your web site:

```yml

####
website:
  install: true
  locale: en_GB.UTF-8
  csp:
    default: "'none'"
    list:
      - id: default-src
        value: "https: 'self'"
      - id: script-src
        value: "https: 'self'"
      - id: img-src
        value: "https: 'self'*.cloudflare.com s3.amazonaws.com"
      - id: style-src
        value: "https: 'self'*.cloudflare.com"
      - id: media-src
        value: "https: 'self' *.cloudflare.com s3.amazonaws.com"
      - id: font-src
        value: "https: 'self' fonts.googleapis.com"
      - id: base-uri
        value: "https: 'self'"
      - id: frame-src
      - id: object-src
      - id: connect-src


  ### Features policy
  fp:
    default: "'self' *.example.com"
    list:
      - id: geolocation
      - id: midi
      - id: notifications
      - id: push
      - id: sync-xhr
        value: "'self'"
      - id: microphone
      - id: camera
      - id: magnetometer
      - id: gyroscope
      - id: speaker
      - id: vibrate
      - id: fullscreen
      - id: payment
        value: "'self' *.payment.site"
```

## More information

- Content security policy reference: https://content-security-policy.com/
- Wikipedia page: https://en.wikipedia.org/wiki/Content_Security_Policy
- Checking the security of your site: https://securityheaders.com/
