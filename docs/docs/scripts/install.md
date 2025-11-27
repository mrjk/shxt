# Install

Production release for [https://mrjk.github.io/shxt/shxt.sh](shxt.sh) is available here on this website.

So to make it live-run and auto-install (require internet the first time):
```bash
#!/bin/bash

# Run or auto-install shxt.sh
. shxt.sh || eval "$(curl -v https://mrjk.github.io/shxt/shxt.sh)"
```

If you are sure you have already installed shxt.sh before:
```bash
#!/bin/bash

# Require shxt to be installed locally
. shxt.sh || { echo "Shxt.sh is missing, check https://mrjk.github.io/shxt/"; exit 1; }
```

If you always want to use the latest version without installation (always require internet):
```bash
#!/bin/bash

# Always require internet connexion to run
eval "$(curl -v https://mrjk.github.io/shxt/shxt.sh)"
```


