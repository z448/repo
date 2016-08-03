# NAME

repo - Creates list of Debian packages and starts APT repository on localhost:3000.

# DESCRIPTION 

'repo' creates MD5, SHA1 and SHA256 hashes of each package in 'deb' directory, checks control file and use it to create Packages.gz file needed by APT client to read content of repository, then starts repository running on Mojolicious server ( localhost:3000 ). 'repo' has dependency on 'curl', it's using it to download perl implementation of 'ar' archiver on first run which is saved into `$HOME/tmp/.repo` directory.

# GIF

![https://raw.githubusercontent.com/z448/repo/master/repo.gif](https://raw.githubusercontent.com/z448/repo/master/repo.gif)

# INSTALLATION

- Install via C<cpan>

```bash
# switch to root
cpan App::Repo
```

- or compile and install it yourself as 'root'

```bash
# switch to root
git clone https://github.com/z448/repo
cd repo/App-repo-0.05
perl Makefile.PL
make
make install
```


# OPTIONS

Pass full path to 'deb' directory containing Debian packages with -d parameter. Repo will generate 'Packages.gz' file in a same directory where 'deb' is located. 

start:                  `repo -d /path/to/deb`

usage:                  `repo -h`

# AUTHOR

Zdenek Bohunek <zed448@icloud.com>

# COPYRIGHT AND LICENSE

Copyright 2016 by Zdenek Bohunek

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
