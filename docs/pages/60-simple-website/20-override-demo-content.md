# Override content

To override the demo content, just upload new site content in
`/var/www/www.<your-domain>`, by following this naming convention:

| file               | Description                        | Override with      |
|--------------------|------------------------------------|--------------------|
| index-demo.html    | Sample index page                  | index-page.html    |
| css/demo.css       | Sample CSS style sheet             | N/A                |
| js/demo.js         | Sample JavaScript file             | N/A                |
| notfound-demo.html | Sample "page not found" error page | notfound-page.html |
| error-demo.html    | Sample "server error" page         | error-page.html    |
| denied-demo.html   | Sample "access denied" page        | denied-page.html   |

Once you have created the default index and optionally the default error pages, you can
remove the demo pages with this command:

```sh
cd playbooks
ROLE=website-simple ansible-playbook -t facts,website install.yml
```

If for any reason, you want to push the content again even if you have customised the
index page:

```sh
cd playbooks
ROLE=website-simple ansible-playbook -e force_push_demo=true -t facts,website install.yml
```

!!! Note
    To quickly customise the web site content and test the publication, see the
    [backup and restore page](50-backup-and-restore.md).
