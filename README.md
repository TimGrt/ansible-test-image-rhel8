# RHEL8 Image for Molecule testing

Container Image, based on UBI8, for testing Ansible content.

A user `ansible` is created with password-less sudo configured. A couple of default packages are installed, but not all packages as in a *normal* RHEL8 installation. Add additional packages in a `prepare.yml` during Molecule *create* stage.

> [!WARNING]
> **RHEL8 uses Python 3.6.8 from `/usr/libexec/platform-python` by default.**  
> Newer Ansible versions require a more recent version of Python3 on target devices!  
> **Use ansible-core <2.17.x** (e.g. 2.16.19) **to be able to automate it**

[![Container Build and Publish](https://github.com/TimGrt/ansible-test-image-rhel8/actions/workflows/cd.yml/badge.svg)](https://github.com/TimGrt/ansible-test-image-rhel8/actions/workflows/cd.yml)

## How to Build

If you need to build the image on your own locally, do the following:

  1. [Install Podman](https://podman.io/docs/installation).
  2. Clone the repository and `cd` into this directory.
  3. Run `podman build -t ansible-test-rhel8 .`

### Build image with newer Python version

To be able to use ansible-core > 2.17.x, upgrade the Python installation on the test image by providing the `PYTHON_VERSION` *build argument*:

```bash
podman build --build-arg PYTHON_VERSION=3.12 -t ansible-test-rhel8:python3.12 .
```

To use the Python3.12 Interpreter, provide the path to it e.g. as a host variable:

```yaml
# host_vars/rhel8_test_instance1.yml
ansible_python_interpreter: /usr/bin/python3.12
```

## How to Use with Molecule

  1. [Install Podman](https://podman.io/docs/installation).
  2. [Install Molecule](https://ansible.readthedocs.io/projects/molecule/installation/).
  3. Install Ansible Collection dependencies: `ansible-galaxy collection install containers.podman`.
  4. Add Image in `molecule.yml`.

For example:

```yaml
---
driver:
  name: podman
platforms:
  - name: rhel8-molecule-test
    image: ghcr.io/timgrt/ansible-test-image-rhel8:main
    groups:
      - molecule
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    command: "/usr/sbin/init"
    pre_build_image: true
    exposed_ports:
      - 80/tcp
    published_ports:
      - 8080:80/tcp
provisioner:
  name: ansible
  config_options:
    defaults:
      interpreter_python: auto_silent
      callbacks_enabled: profile_tasks, timer
      callback_result_format: yaml
      remote_user: ansible
      roles_path: "$MOLECULE_PROJECT_DIRECTORY/.."
    ssh_connection:
      pipelining: false
scenario:
  create_sequence:
    - create
  converge_sequence:
    - create
    - converge
  destroy_sequence:
    - destroy
  test_sequence:
    - destroy
    - create
    - syntax
    - converge
    - idempotence
    - destroy

```

The example above uses Callback plugins from `ansible.posix`.
