# tls-ping

TLS ping host and port.

## Introduction

**tls-ping** connects to a given host and port and validates the TLS connection
and certificate.

## Installation

```bash
gem build
version=$(ruby -Ilib -e 'require "tls/ping"; puts TLS::Ping::VERSION')
gem install tls-ping-${version}.gem
```

## Usage

```bash
$ tls-ping github.com 443
> github.com:443
   [ OK ] /CN=github.com
```

For further information about the command line tool `tls-ping` see the following
help output.

```bash
Usage:
    tls-ping [OPTIONS] HOST PORT

Parameters:
    HOST                     hostname to ping
    PORT                     port to ping

Options:
    -s, --starttls           use STARTTLS
    -t, --timeout SECONDS    timeout in seconds (default: 5)
    -q, --quiet              suppress output
    -h, --help               print help
    -m, --man                show manpage
    -v, --version            show version
```

## License

[MIT License](https://spdx.org/licenses/MIT.html)

## Is it any good?

[Yes.](https://news.ycombinator.com/item?id=3067434)
