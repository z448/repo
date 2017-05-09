# NAME

**repo** - create debian repository

# DESCRIPTION 

**repo** creates MD5, SHA1 and SHA256 hashes of each package in `deb` directory, checks control file and use it to create `Packages.gz` file needed by APT client to read content of repository, then starts repository running on Mojolicious server ( port 3000 ).

# GIF

![https://raw.githubusercontent.com/z448/repo/master/repo.gif](https://raw.githubusercontent.com/z448/repo/master/repo.gif)

# INSTALLATION

- Install via cpan

```bash
# switch to root
cpan App::Repo
```

- or compile and install it yourself

```bash
# switch to root
git clone https://github.com/z448/repo
cd repo/App-repo-0.07
perl Makefile.PL
make
make install
```

# OPTIONS

-d parameter takes full path to `deb` directory containing .deb files. Repo will generate 'Packages.gz' file in a same directory where 'deb' is located and starts APT repository on port 3000.

start:                  "repo -d /path/to/deb"

stop:                   "repo -stop"

status:                 "repo -status"

update packages list:   "repo -d /path/to/deb -p"

help:                   "repo -h"

# AUTHOR

Zdenek Bohunek <zed448@icloud.com>

# COPYRIGHT AND LICENSE

Copyright 2016 by Zdenek Bohunek

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
