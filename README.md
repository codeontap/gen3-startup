**Deprecated**

This repository is no longer used and has been archived

Bootstrap scripts should be included as part of the engine using either prologue/epilogue scripts or generated as part of init scripts

# Hamlet Engine - Startup

This is the repository for Startup, a part of the Hamlet Deploy application. It provides a number of server bootstrap capabilities to Hamlet Deploy.

See https://docs.hamlet.io for more info on Hamlet Deploy

### Installation

```bash
git clone https://github.com/hamlet-io/cloudinit-aws.git
```

### Configuration

Startup requires the following Environment Variable(s) in order to function.

| Variable            | Value                                                                                    |
|---------------------|------------------------------------------------------------------------------------------|
| GENERATION_STARTUP_DIR | A fully qualified filepath to the cloned `./startup` directory |

### Update

To manually perform an update of Startup, simply pull down the latest changes using git.

```bash
cd ./path/to/startup
git pull
```

### Usage

The scripts within Startup are typically invoked during a deployment of specific Hamlet Deploy Components and are not intended for running manually in a terminal.

Each script has a specific use-case (such as bootstrapping a particular cloud compute resource), and new scripts are strongly encouraged over re-purposing those existing ones as their purposes may diverge.
