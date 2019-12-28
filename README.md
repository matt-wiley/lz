# landing-zone

This project builds upon and revamps the work done by the contributors to [desk](https://github.com/jamesob/desk).

This derivative was developed on MacOS Mojave and designed for use in the bash environments therein. Also, it is HIGHLY OPINIONATED to my own personal use case, and likely has compatibility issues with your personal flavor of terminal environment.

All of that said it is easy to install, use, and even customize with a bit of shell script - hell, that's where it started in the first place.

**I cannot stess enough how *awesome* I think the work on [desk](https://github.com/jamesob/desk) is.** This project takes that concept and tweaks a few things.

1) Instead of a creating `desk`s you create `lz`s. 
  - This is mostly a renaming, but there is a conceptual change to store the actual `lz` file WITHIN the project-space or codebase rather than in a centralized directory. 
 
2) `lz`s are registred centrally in a `zones` directory as symlinks
  - This means that the new shell and sourcing mechanic is largely identical to that used in [desk](https://github.com/jamesob/desk), we're just using "in situ" environment files - `lz`s - instead.

3) From within any directory a new `lz` can be created and registered using the `lz new` (or `lndr new`) commands.
  - This creates a `.lz` file in that directory. This file is a copy of a template `initial.lz` file slightly modified for this particular directory.
  - This also creates a symlink in the main `zones` directory using the name of the directory as the zone id. This zone id is how a zone can be "landed in" using `lz <zone_id>`

4) There is a `master.lz` file which is `source`d in the `initial.lz` file used when creating a new `lz`. This is handy for keeping some logic common to all `zones` and being able to update that logic quickly so that all `zones` inherit the updates automatically.

5) There is built-in tab completion for zone ids when running the `lz` or `lndr` commands. Although you can still list out all registered `zones` if needed.

6) The ability to `run` commands in a `lz` (nee. `desk`) without manually loading into it has been omitted for the time being. It wasn't a feature I used.

## Installation

There is an install script included in the `bin` directory in this repo which will handle the download, install, and setup of the files need for `lz` to work properly.

Simply run the following in your terminal.

```bash
curl -fsSL https://raw.githubusercontent.com/wileymab/landing-zone/master/.lndr/bin/install.sh | bash --
```

NOTE: This install requires `unzip` to be installed and will attempt to install is via `sudo apt-get ...` if it is not found. You may be prompted for you password for this. 

NOTE: A symlink is created in `/usr/local/bin` for the `lndr.sh` script once downloaded. This is executed using `sudo ln -s ...`. You may be prompted for you password for this. 

## Usage

### Creating a new landing zone.
```bash
# From desired landing zone directory (typically codebase or project root)
# Example: ~/dev/myProject
> lz new
```

Given an out-of-the-box install and the exmaple path above, this command would create `~/dev/myProject/.lz`, and that file would be symlinked at `~/.lndr/zones/myProject`. That's it! This `lz` is ready for use and can be loaded.

### Loading a landing zone.
```bash
> lz myProject
```
Continuing the example, if we run the command above we will "load" the `myProject` zone and be dropped into a new shell in the root directory of that project (where the `.lz` file is located) and our new shell will have the `.lz` file `source`d into it's environment.

NOTE: Only one zone can be loaded at a time and you can only load up one zone deep. If you are already in a loaded zone and try to load another, the load wil fail and you will need to exit your current shell (or open a new terminal tab/window/etc.) to load another.

### `exit`ing a landing zone.
```bash
> exit
```
This one's really simple. We're using standard shells as our `lz`s, so leaving one is as simple as executing the shell `exit` built-in. This will return you to the parent shell and whatever you were doing prior to loading your zone.

### Listing zones in the registry.
```bash
> lz list [-l|--long]
```
You can see all registered zones by executing the `lz list` command. By default the `list` command will return a simple bash list of the zone ids, much like a basic `ls` command.

```bash
> lz list
myProject  # any other zone ids would be listed here
```

Using the `-l` or `--long` flag gives a more complete tabular view of the zones that are registered. This includes any descriptors setup in the `.lz` file itself.

```bash
# Long listing
> lz list -l  # or, lz list --long

Zone ID         | Zone Name            | Zone Description
--------------- | -------------------- | --------------------
myProject       | Default name         | Default description
.
.
.

```

### Adding names and descriptions to `lz`s.
```bash
#!usr/bin/env bash
if [[ -z "${LANDER_HOME}" ]]; then echo "LANDER_HOME is not set."; exit 1; fi
source ${LANDER_HOME}/master.lz

#lz.name Default name
#lz.desc Default description
initZone /home/dev/myProject
```
The top of each `.lz` file includes two comment lines each of which is prefixed with `#lz.`. These comments are special and allow you to name and describe your zones with more information. Anything provided after `#lz.name ` or `#lz.desc ` is used as the name or description value, respectively. And these values will show up in the CLI when listing all zones or attempting to load a over another.

NOTE: The name and description are limited to a single line. Any more than that should probably be in README in your project directory.

### Adding your stuff to `lz`s
```bash
#!usr/bin/env bash
if [[ -z "${LANDER_HOME}" ]]; then echo "LANDER_HOME is not set."; exit 1; fi
source ${LANDER_HOME}/master.lz

#lz.name Default name
#lz.desc Default description
initZone /home/dev/myProject

<your_stuff here>
```

This is where the power of [desk](https://github.com/jamesob/desk) is preserved. After the first 6 lines of you `.lz` file, the rest is yours to customize however you like. Add aliases, functions, etc. as needed. Create whatever setup you need to make sure you're getting the most out of your `lz` for your project(s).

Have fun with with it! **BUT REMEMBER**: If you're going to keep sensitive information in this file such as api tokens, JWTs, passwords, etc. make sure it is *NOT COMMITTED TO VSC*. 
