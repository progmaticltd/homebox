# Troubleshooting

If everything works correctly, you can jump to the next section, _after the installation_.

If something goes wrong, or if you want to see more details, use the following command to run the installation in
verbose mode:

```sh
cd playbooks
ansible-playbook -vv install-version.yml
```

## No password for root

If you see this:

```sh
fatal: [homebox]: FAILED! =>
  msg: Missing sudo password
```

You probably forgot to add the user to the sudo group, see the [Prepare your target](/10-prepare-your-target/) section.

## Mailing lists

Thanks to [Framasoft](https://framasoft.org/), two mailing lists have been created, one for general questions,
suggestions and support, and another one dedicated for development.

- General questions: [homebox-general](https://framalistes.org/sympa/info/homebox-general).
- Development: [homebox-dev](https://framalistes.org/sympa/info/homebox-dev).
