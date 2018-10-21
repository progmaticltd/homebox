#!/usr/bin/env python3

import subprocess

from ansible.plugins.connection.ssh import Connection as ConnectionSSH

DOCUMENTATION = '''
    connection: ssh_fwknop
    short_description: Send SPA before accessing the server
    description:
        - This plugin uses fwknop to open the SSH port before running ansible
    author: Homebox <andre@homebox.space>
    version_added: na
    options:
      host:
          description: Hostname/ip to connect to.
          default: inventory_hostname
          vars:
               - name: ansible_host
               - name: ansible_ssh_host
      host_key_checking:
          description: Determines if ssh should check host keys
          type: boolean
          ini:
              - section: defaults
                key: 'host_key_checking'
              - section: ssh_connection
                key: 'host_key_checking'
                version_added: '2.5'
          env:
              - name: ANSIBLE_HOST_KEY_CHECKING
              - name: ANSIBLE_SSH_HOST_KEY_CHECKING
                version_added: '2.5'
          vars:
              - name: ansible_host_key_checking
                version_added: '2.5'
              - name: ansible_ssh_host_key_checking
                version_added: '2.5'
      password:
          description: Authentication password for the C(remote_user). Can be supplied as CLI option.
          vars:
              - name: ansible_password
              - name: ansible_ssh_pass
      ssh_args:
          description: Arguments to pass to all ssh cli tools
          default: '-C -o ControlMaster=auto -o ControlPersist=60s'
          ini:
              - section: 'ssh_connection'
                key: 'ssh_args'
          env:
              - name: ANSIBLE_SSH_ARGS
      ssh_common_args:
          description: Common extra args for all ssh CLI tools
          ini:
              - section: 'ssh_connection'
                key: 'ssh_common_args'
                version_added: '2.7'
          env:
              - name: ANSIBLE_SSH_COMMON_ARGS
                version_added: '2.7'
          vars:
              - name: ansible_ssh_common_args
      ssh_executable:
          default: ssh
          description:
            - This defines the location of the ssh binary. It defaults to `ssh` which will use the first ssh binary available in $PATH.
            - This option is usually not required, it might be useful when access to system ssh is restricted,
              or when using ssh wrappers to connect to remote hosts.
          env: [{name: ANSIBLE_SSH_EXECUTABLE}]
          ini:
          - {key: ssh_executable, section: ssh_connection}
          yaml: {key: ssh_connection.ssh_executable}
          #const: ANSIBLE_SSH_EXECUTABLE
          version_added: "2.2"
          vars:
              - name: ansible_ssh_executable
                version_added: '2.7'
      sftp_executable:
          default: sftp
          description:
            - This defines the location of the sftp binary. It defaults to ``sftp`` which will use the first binary available in $PATH.
          env: [{name: ANSIBLE_SFTP_EXECUTABLE}]
          ini:
          - {key: sftp_executable, section: ssh_connection}
          version_added: "2.6"
          vars:
              - name: ansible_sftp_executable
                version_added: '2.7'
      scp_executable:
          default: scp
          description:
            - This defines the location of the scp binary. It defaults to `scp` which will use the first binary available in $PATH.
          env: [{name: ANSIBLE_SCP_EXECUTABLE}]
          ini:
          - {key: scp_executable, section: ssh_connection}
          version_added: "2.6"
          vars:
              - name: ansible_scp_executable
                version_added: '2.7'
      scp_extra_args:
          description: Extra exclusive to the ``scp`` CLI
          vars:
              - name: ansible_scp_extra_args
          env:
            - name: ANSIBLE_SCP_EXTRA_ARGS
              version_added: '2.7'
          ini:
            - key: scp_extra_args
              section: ssh_connection
              version_added: '2.7'
      sftp_extra_args:
          description: Extra exclusive to the ``sftp`` CLI
          vars:
              - name: ansible_sftp_extra_args
          env:
            - name: ANSIBLE_SFTP_EXTRA_ARGS
              version_added: '2.7'
          ini:
            - key: sftp_extra_args
              section: ssh_connection
              version_added: '2.7'
      ssh_extra_args:
          description: Extra exclusive to the 'ssh' CLI
          vars:
              - name: ansible_ssh_extra_args
          env:
            - name: ANSIBLE_SSH_EXTRA_ARGS
              version_added: '2.7'
          ini:
            - key: ssh_extra_args
              section: ssh_connection
              version_added: '2.7'
      retries:
          # constant: ANSIBLE_SSH_RETRIES
          description: Number of attempts to connect.
          default: 3
          type: integer
          env:
            - name: ANSIBLE_SSH_RETRIES
          ini:
            - section: connection
              key: retries
            - section: ssh_connection
              key: retries
          vars:
              - name: ansible_ssh_retries
                version_added: '2.7'
      port:
          description: Remote port to connect to.
          type: int
          default: 22
          ini:
            - section: defaults
              key: remote_port
          env:
            - name: ANSIBLE_REMOTE_PORT
          vars:
            - name: ansible_port
            - name: ansible_ssh_port
      remote_user:
          description:
              - User name with which to login to the remote server, normally set by the remote_user keyword.
              - If no user is supplied, Ansible will let the ssh client binary choose the user as it normally
          ini:
            - section: defaults
              key: remote_user
          env:
            - name: ANSIBLE_REMOTE_USER
          vars:
            - name: ansible_user
            - name: ansible_ssh_user
      pipelining:
          default: ANSIBLE_PIPELINING
          description:
            - Pipelining reduces the number of SSH operations required to execute a module on the remote server,
              by executing many Ansible modules without actual file transfer.
            - This can result in a very significant performance improvement when enabled.
            - However this conflicts with privilege escalation (become).
              For example, when using sudo operations you must first disable 'requiretty' in the sudoers file for the target hosts,
              which is why this feature is disabled by default.
          env:
            - name: ANSIBLE_PIPELINING
            #- name: ANSIBLE_SSH_PIPELINING
          ini:
            - section: defaults
              key: pipelining
            #- section: ssh_connection
            #  key: pipelining
          type: boolean
          vars:
            - name: ansible_pipelining
            - name: ansible_ssh_pipelining
      private_key_file:
          description:
              - Path to private key file to use for authentication
          ini:
            - section: defaults
              key: private_key_file
          env:
            - name: ANSIBLE_PRIVATE_KEY_FILE
          vars:
            - name: ansible_private_key_file
            - name: ansible_ssh_private_key_file
      control_path:
        description:
          - This is the location to save ssh's ControlPath sockets, it uses ssh's variable substitution.
          - Since 2.3, if null, ansible will generate a unique hash. Use `%(directory)s` to indicate where to use the control dir path setting.
        env:
          - name: ANSIBLE_SSH_CONTROL_PATH
        ini:
          - key: control_path
            section: ssh_connection
        vars:
          - name: ansible_control_path
            version_added: '2.7'
      control_path_dir:
        default: ~/.ansible/cp
        description:
          - This sets the directory to use for ssh control path if the control path setting is null.
          - Also, provides the `%(directory)s` variable for the control path setting.
        env:
          - name: ANSIBLE_SSH_CONTROL_PATH_DIR
        ini:
          - section: ssh_connection
            key: control_path_dir
        vars:
          - name: ansible_control_path_dir
            version_added: '2.7'
      sftp_batch_mode:
        default: 'yes'
        description: 'TODO: write it'
        env: [{name: ANSIBLE_SFTP_BATCH_MODE}]
        ini:
        - {key: sftp_batch_mode, section: ssh_connection}
        type: bool
        vars:
          - name: ansible_sftp_batch_mode
            version_added: '2.7'
      scp_if_ssh:
        default: smart
        description:
          - "Prefered method to use when transfering files over ssh"
          - When set to smart, Ansible will try them until one succeeds or they all fail
          - If set to True, it will force 'scp', if False it will use 'sftp'
        env: [{name: ANSIBLE_SCP_IF_SSH}]
        ini:
        - {key: scp_if_ssh, section: ssh_connection}
        vars:
          - name: ansible_scp_if_ssh
            version_added: '2.7'
      use_tty:
        version_added: '2.5'
        default: 'yes'
        description: add -tt to ssh commands to force tty allocation
        env: [{name: ANSIBLE_SSH_USETTY}]
        ini:
        - {key: usetty, section: ssh_connection}
        type: bool
        vars:
          - name: ansible_ssh_use_tty
            version_added: '2.7'
      fwknop_src:
        default: 'auto'
        description: Default source IP address to use for fwknop
        env: [{name: FWKNOP_SRC}]
        ini:
        - {key: fwknop_src, section: ssh_connection}
        type: string
        vars:
          - name: fwknop_src
            version_added: '2.7'
      fwknop_dest:
        description: default destination address / domain to send SPA traffic
        env: [{name: FWKNOP_DEST}]
        ini:
        - {key: fwknop_dest, section: ssh_connection}
        type: string
        vars:
          - name: fwknop_dest
            version_added: '2.7'
      fwknop_rc_file:
        default: 'auto'
        description: Configurlation file to read for fwknop
        env: [{name: FWKNOP_RC_FILE}]
        ini:
        - {key: fwknop_rc_file, section: ssh_connection}
        type: string
        vars:
          - name: fwknop_rc_file
            version_added: '2.7'
      fwknop_verbose:
        version_added: '2.5'
        default: 'yes'
        description: Use verbose output flags for fwknop
        env: [{name: FWKNOP_VERBOSE}]
        ini:
        - {key: fwknop_verbose, section: ssh_connection}
        type: bool
        vars:
          - name: fwknop_verbose
            version_added: '2.7'
      fwknop_config_name:
        version_added: '2.5'
        description: Configuration name to use (-n)
        env: [{name: FWKNOP_CONFIG_NAME}]
        ini:
        - {key: fwknop_config_name, section: ssh_connection}
        type: string
        vars:
          - name: fwknop_config_name
            version_added: '2.7'
      fwknop_executable:
        version_added: '2.5'
        default: '/usr/bin/fwknop'
        description: path to the fwknop executable
        env: [{name: FWKNOP_EXECUTABLE}]
        ini:
        - {key: fwknop_executable, section: ssh_connection}
        type: bool
        vars:
          - name: fwknop_executable
            version_added: '2.7'
      fwknop_extra_args:
        version_added: '2.5'
        description: extra arguments for fwknop client
        env: [{name: FWKNOP_EXTRA_ARGS}]
        ini:
        - {key: fwknop_extra_args, section: ssh_connection}
        type: string
        vars:
          - name: fwknop_extra_args
            version_added: '2.7'
'''

from ansible.errors import AnsibleError
from socket import create_connection
from time import sleep
from pprint import pprint

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

class Connection(ConnectionSSH):
    ''' Run fwknop port knocker before accessing the server '''

    def __init__(self, play_context, new_stdin, *args, **kwargs):

        super(Connection, self).__init__(play_context, new_stdin, *args, **kwargs)

        display.vv("ssh_fwknop connection plugin is used for this host", host=self.host)

    def _connect(self):

        parameters = []

        # Check for a custom executable, or use /usr/bin/fwknop on Linux
        executable = self._options[u'fwknop_executable'] or '/usr/bin/fwknop'
        parameters.append(executable)

        # Verbose output or not
        verbose = self._options[u'fwknop_verbose'] or False
        if verbose:
            parameters.append('-v')

        # Source: if auto, use the '-R' fwknop option
        src = self._options[u'fwknop_src'] or "auto"
        if src == "auto":
            parameters.append('-R')
        else:
            parameters.append('-a')
            parameters.append(src)

        # Destination: Should be specified
        dest = self._options[u'fwknop_dest'] or None
        if dest == None:
            raise AnsibleError("You should specify the destination argument (fwknop_dest)")
        parameters.append('-D')
        parameters.append(dest)

        # Configuration file
        rc_file = self._options[u'fwknop_rc_file'] or None
        if rc_file != None:
            parameters.append('--rc-file')
            parameters.append(rc_file)

        # Named config to use
        fwknop_config_name = self._options[u'fwknop_config_name'] or None
        if fwknop_config_name != None:
            parameters.append('-n')
            parameters.append(fwknop_config_name)

        # Extra arguments
        fwknop_extra_args = self._options[u'fwknop_extra_args'] or None
        if fwknop_extra_args != None:
            for arg in fwknop_extra_args.split(' '):
                parameters.append(arg)

        p = subprocess.Popen(parameters,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        display.vvv("Running '" + str.join(" ", parameters) + "'")

        stdout, stderr = p.communicate()
        status_code = p.wait()

        display.vvv(stdout)
        display.vvv(stderr)

        if status_code != 0:
            raise AnsibleError("fwknop error:\n%s" % stderr)

        return self
