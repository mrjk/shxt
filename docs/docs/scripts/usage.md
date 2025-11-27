# Usage

Once shxt.sh is available, you can use it's API. The API is quite simple and minimalist. Thus, it offers a simple API following the syntax:

```bash
loader ACTION KIND NAME [URL]
```

Where action is mostly `use`, kind one of bin, lib or files. And then you set a name and a source URL as fallback.

## Basic usage

Thus, to use [yadm]() in your project, you can either distribute the source code of yadm in your project, either you can fetch it from remote URL:

```bash
# Ensure yadm file in bin/yadm is executable
loader use bin yadm

# Same as above, but auto-install yadm if not distributed
loader use bin yadm https://raw.githubusercontent.com/yadm-dev/yadm/refs/heads/master/yadm
```

Then you can access to yadm directly:
```bash
yadm help
command -v yadm
echo $PATH
```


So to use various tools in your script, you can use:
```bash
loader use bin hr https://raw.githubusercontent.com/LuRsT/hr/refs/heads/master/hr
loader use bin esh https://raw.githubusercontent.com/jirutka/esh/refs/heads/master/esh
loader use bin has https://raw.githubusercontent.com/kdabir/has/refs/heads/master/has
loader download bin spark https://raw.githubusercontent.com/holman/spark/refs/heads/master/spark
```

It is possible to use any references, like a branch or specific tag.

Note: When you select a project on github, don't forget to use url starting by https://raw.githubusercontent.com.


It also works for binaries, directly via the public github release API:
```bash
loader use bin mise https://github.com/jdx/mise/releases/download/v2024.1.0/mise-v2024.1.0-linux-x64

loader download bin direnv https://github.com/direnv/direnv/releases/download/v2.37.1/direnv.linux-amd64
```

## Enable debug logging

Use the `SHXT_DEBUG` environment variable to set debug mode:
```bash
SHXT_DEBUG=true myapp.sh 
```

Use the `SHXT_TRACE` environment variable to enable trace mode:
```bash
SHXT_TRACE=true myapp.sh
```


## Bash strict mode

It should be compatible :) Use like this:

```bash
#!/bin/bash

# Enable strict mode
set -eu -o pipefail

# Run or auto-install shxt.sh
. shxt.sh || eval "$(curl -v https://mrjk.github.io/shxt/shxt.sh)"
```

## Specific read/write directory

It is possible to either use command option or environment variable.

To implement.

## Read-only environments

This is not supported at the moment, eventually a reduced feature mode can be implemented.

## With development releasing

Since the shell source code is directly published through website, it is possible
to adapt for development mode. Start local instance:

```bash
cd docs
mkdics serve
```

In script
```bash
#!/bin/bash

eval "$(curl -v http://127.0.0.1:8000/shxt/shxt.sh)"
```
