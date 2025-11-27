# Advanced

We cover here some advanced topics.

## Rationale

### Why this strange release process

Because this is actually possible.

### Single source file

This make life easier:
* simple to maintain
* try to keep code simple and minimal
* reduced dowload times because smaller files
* super simple but unlock unlimited possibilities

### Bash and not POSIX

Maybe later. Eventually. Why not ?

### Bash and not other

Please reimplement it yourself for your favorite shell :-) I'll post a link here.


## Technical points

### First writable $PATH directory for auo-install

shxt.sh is configured to auto-install itself, to simply cache itself. While
this behavior can be


### Data storage and cache

When used in live terminal instance, data is always stored in home directory, since sxht.sh need to cache files.

It will try many different paths until it find one. But it is possible to change this behavior with a command flag or environment variable.

To implement.


## Development

We use strict bash by default, follow the bash linter rules.

### Project layout

    shxt.sh           # Shxt.sh single file source code
    docs/             # Provide documentation and release
        mkdocs.yml    # The configuration file.
        index.md      # The documentation homepage.
        ...           # Other markdown pages, images and other files.

