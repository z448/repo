# repo

Creates Packages.gz and starts repository on localhost:3000

# INSTALLATION

```bash
#switch to root
cpan App::Repo
```

# SYNOPSIS

repo creates Packages.gz file needed by APT client to read content of repository, then starts repository running on Mojolicious server on localhost:3000. On iOS you can then add "localhost:3000" into Cydia sources.

# USAGE

start:                  `repo -d /path/to/ded`

usage:                  `repo -h`

