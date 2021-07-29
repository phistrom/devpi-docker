# devpi Docker Container
Simple, quick PyPI mirror or private repo in a container

## Usage

### Start a PyPI mirror

```sh
docker run --restart always -d -p 3141:3141 -v devpi:/devpi --name pypi-mirror phistrom/devpi
```

It's ready to go. You can tell pip to use it by specifying the `-i` flag.

To borrow [the devpi documentation's examples]:
#### Install Package
```sh
pip install -i http://localhost:3141/root/pypi/+simple/ simplejson
```

#### Search for Package
or for search:
```sh
pip search -i http://localhost:3141/root/pypi/ devpi-client
```

### Overrides
devpi-server can already be configured by [environment variables].

#### Secretfile
By default, a random secret file is generated at `/secretfile`.

*  You can mount your own secretfile as a volume like `docker run -v /home/user/mysecretfile:/secretfile ...`
*  You can specify its contents with your own environment variable `docker run -e SECRETFILE_CONTENTS="SUPERSECRETSTUFF" ...` (needs to be at least 32 characters)


[environment variables]: <https://devpi.net/docs/devpi/devpi/stable/+d/quickstart-server.html#using-environment-variables-for-devpi-server-configuration>
[the devpi documentation's examples]: <https://devpi.net/docs/devpi/devpi/stable/+d/quickstart-pypimirror.html#install-your-first-package-with-pip-easy-install>
