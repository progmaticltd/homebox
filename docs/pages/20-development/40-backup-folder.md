# The backup folder


## Plain text credentials

When running the roles, any generated credential is saved in this folder, excluded from
git. The credentials are saved in plain text file by default, which is probably enough for
development. For live systems, you can use the excellent *password-store* instead.

The hierarchy is like this: `backup/<domain>/...`

To save or create credentials, we do not use directly the _password_ or _passwordstore_
lookup, but an abstraction layer, like the example below:

```yml
- name: Create a custom api key
  no_log: '{{ hide_secrets }}'
  ansible.builtin.set_fact:
    api_key: >-
      {{ lookup(creds.store, creds.prefix + "/dns/api-key" +
      creds.opts.create + creds.opts.system)
      }}
  tags: config
```

This has the following advantages:

- The user can use both plain text and _pass_ to store and retrieve credentials.
- Other certificate lookup methods can be added later without changing the code.
- You don't have to guess the prefix path to save the credential, it is automatically set.

!!! Note When working on a development system `system.devel=true`, the hide_secrets is set
    to false, and the secrets are displayed in the console when created or retrieved.


## Other files

Any role can implement backup and restore tasks, for instance, the certificate role,
whatever for testing out-of-date certificates, for quicker development or redeployment, it
is possible to backup and restore the certificates, using the following commands:

Certificates backup:

```sh
ROLE=certificates ansible-playbook backup.yml
```

Certificates restore:

```sh
ROLE=certificates ansible-playbook restore.yml
```
