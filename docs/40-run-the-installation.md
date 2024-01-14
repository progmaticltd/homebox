# Run the installation

Now, the serious things starts.

The first - and hopefully only needed task is too run the playbook for the version you chose. This can be done with the
following command:

```sh
ansible-playbook -e version=<version you choose> playbooks/install-version.yml
```

For instance, for the _large_ version:

```sh
ansible-playbook -e version=large playbooks/install-version.yml
```

If you don't specify the version, by default, the `small` version will be installed.

```sh
ansible-playbook playbooks/install-version.yml
```
