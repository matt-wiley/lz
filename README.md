# landing-zone (aka. `lndr`, aka. `lz`)

> This project builds upon and revamps the work done by the contributors to [desk](https://github.com/jamesob/desk).
>
> This derivative was developed on MacOS Mojave and designed for use in the bash environments therein. Also, it is HIGHLY OPINIONATED to my own personal use case, and likely has compatibility issues with your personal flavor of terminal environment.
>
> All of that said it is easy to install, use, and even customize with a bit of shell script.

**I cannot stress enough how *awesome* I think the work on [desk](https://github.com/jamesob/desk) is.** This project takes that concept and tweaks a few things.


#### 1) Instead of a creating `desk`s you create `lz`s. 

This is mostly a renaming, but there is an important conceptual change. `LZ` stores the actual workspace file (the `.lz` file) WITHIN the project directory or code base rather than in a centralized directory. This makes it intuitive to edit as needed. 
 
#### 2) `lz`s are registered centrally in a `zones` directory as symlinks

This means that the new shell and sourcing mechanic is largely identical to that used in [desk](https://github.com/jamesob/desk), we're just using "in situ" environment files - `lz`s - instead.

#### 3) From within any directory a new `lz` can be created and registered using the `lz new` (or `lndr new`) commands.

This creates a `.lz` file in that directory. This file is a copy of a template `initial.lz` file slightly modified for this particular directory.

This also creates a symlink in the main `zones` directory using the name of the directory as the zone id. This zone id is how a zone can be "landed in" using `lz <zone_id>`

#### 4) There is a `master.lz` file which is `source`d in the `initial.lz` file used when creating a new `lz`.

This is handy for keeping some logic common to all `zones` and being able to update that logic quickly so that all `zones` inherit the updates automatically.

#### 5) There is built-in tab completion for zone ids when running the `lz` or `lndr` commands. 

(Although you can still list out all registered `zones` if needed.)

#### 6) The ability to `run` commands in an `lz` (nee. `desk`) without manually loading into it has been omitted.

This wasn't a feature I used. So I've left it for future implementation.

## Installation

Simply run the following in your terminal.

```bash
curl -fsSL https://gitlab.com/mattwiley/lz/-/raw/main/install.sh | bash --
```

## Usage

### Creating a new `lz`

```bash
# From desired landing zone directory (typically codebase or project root)
# Example: ${HOME}/dev/myProject
> lz new
```

Given an out-of-the-box install and the example path above, this command would create `${HOME}/dev/myProject/.lz`, and that file would be symlinked at `${HOME}/.lndr/zones/myProject`. That's it! This `lz` is ready for use and can be loaded.

### Loading an `lz`

```bash
> lz myProject
```

Continuing the example, if we run the command above we will "load" the `myProject` zone and be dropped into a new shell in the root directory of that project (where the `.lz` file is located) and our new shell will have the `.lz` file `source`d into its environment.

> **!! NOTE !!** 
> Only one zone can be loaded at a time and you can only load up one zone deep. If you are already in a loaded zone and try to load another, the load will fail and and present you with a message about why. You need to `exit` your current shell (or open a new terminal tab/window/pane/etc.) to load another zone.

### `exit`ing an `lz`

```bash
> exit
```

This one's really simple. We're using standard shells as our `lz`s, so leaving one is as simple as executing the shell `exit` built-in. This will return you to the parent shell and whatever you were doing prior to loading your zone.

### Listing the registered zones with `lz ls`

```bash
> lz ls [-l|--long]
```

You can see all registered zones by executing the `lz ls` command. By default the `ls` command will return a simple bash list of the zone ids, much like a basic `ls` command.

```bash
> lz ls
myProject  # any other zone ids would be listed here
```

Using the `-l` or `--long` flag gives a more complete tabular view of the zones that are registered. This includes any descriptors setup in the `.lz` file itself.

```bash
# Long listing
> lz ls -l  # or, lz ls --long

Zone ID         | Zone Name            | Zone Description
--------------- | -------------------- | --------------------
myProject       | Default name         | Default description
.
.
.

```

### Adding names and descriptions to `lz`s

```bash
#!usr/bin/env bash
if [[ -z "${LANDER_HOME}" ]]; then echo "LANDER_HOME is not set."; exit 1; fi
source ${LANDER_HOME}/master.lz

#lz.name Default name
#lz.desc Default description
initZone /home/dev/myProject
```

The top of each `.lz` file includes two comment lines each of which is prefixed with `#lz.`. These comments are special and allow you to name and describe your zones with more information. Anything provided after `#lz.name ` or `#lz.desc ` is used as the name or description value, respectively. And these values will show up in the CLI when listing all zones or attempting to load a over another.

> &nbsp;
> **!! NOTE !!**
> The name and description are limited to a single line. Any more than that should probably be in a README in your project directory.
> &nbsp;

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

Have fun with with it! **BUT REMEMBER**: If you're going to keep sensitive information in this file such as api tokens, JWTs, passwords, etc. make sure it is *NOT COMMITTED TO VCS*. 

## Development

### Testing

The cleanest way to test this project is to run the tests inside a docker container. This is how the tests are executed in CI. To emulate the CI process locally use the following steps.

#### Prerequisites

- `python 3.8+` is installed on your machine
- `docker` is installed on your machine


#### Running Tests

Tests are written using [Shellspec](https://github.com/shellspec/shellspec#shellspec). They can be found under the [spec folder](./spec/). Setup, test, and teardown are handled via the [test_runner.sh script](.scripts/test_runner.sh).

##### Step 1: Start a local web server

The installation process for LZ involves downloading various files to a known location. To support this locally (and speed up the development process) we first need to run an HTTP web server out of the project root directory. This will allow the installation to mimic downloading resources from GitHub.

```shell
# From the project root directory
> python -m http.server 8080
```

> **Note:** This guide assumes the use of `python`, but any available web server will do. We recommend this because of the easy of use, but feel free to use whatever you're familiar with.

> **Note:** Port `8080` is important. It is hardcoded in the [test_runner.sh script](.scripts/test_runner.sh). If you need to run the web server on a different port you will need to change the port in the [test_runner.sh script](.scripts/test_runner.sh)

##### Step 2: Run the tests

To run the test cleanly we run them inside a container that already has [Shellspec](https://github.com/shellspec/shellspec#shellspec) installed. When we execute the [test_runner.sh script](.scripts/test_runner.sh), we pass it the `docker` argument to ensure it uses the correct `BASE_URL` and download the resources from our local web server.

```shell
# From the project root directory
> docker run -it --rm -v "$(pwd):$(pwd)" -w "$(pwd)" \
    --network host mattwiley/shellspec \
    bash -c ".scripts/test_runner.sh docker"
```

> **Note:** A slightly modifed version of the command above is provided as a Make target. If you have the `make` build tooling installed you can run tests with:
> 
> ```shell
> # From the project root directory
> > make test
> ```