# Server side includes

This is useful if you are developing a site using pure HTML, and not using a static site
content generator, not to mention a dynamic language like PHP, Go, Node, etc or even
framework based on.

Still, to avoid repeating content on each pages, like site headers and footers, you can
use nginx server side includes. Below an example to use them.

First, set the _ssi_ flag to `true` in your website configuration:

```yml
website:
  […]
  ssi: true
```

Then, create a folder `/var/www/<your-domain>/.include/` on your server, and upload any
HTML file you want. Here a very basic example with a file called `html-header.html` with
this content:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" media="screen" href="/css/layout-screen-all.css">
<script defer src="/js/page.js"></script>
```

Now, any page can include the header, using this code:

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <!--# include file=".include/html-headers.html" -->
        <title>My beautiful web site</title>
    </head>
    <body>
        ...
    </body>
</html>

```

!!! Note
    This folder starts with a `.`, and is automatically excluded by _nginx_, and
    would return an error "403 Forbidden".
