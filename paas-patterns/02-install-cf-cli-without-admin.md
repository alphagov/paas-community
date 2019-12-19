# Install the Cloud Foundry command line interface (CLI) without admin access

## Problem

You want to install the cloud foundry cli on OSX but do not have admin privileges, the pkg installer and homebrew installers require an admin profile.

## Solution

Install the CLI using the tarball rather than the pkg installer

```
curl -L -o cli-tar.gz 'https://packages.cloudfoundry.org/stable?release=macosx64-binary&source=github'
tar zxvf cli-tar.gz
./cf help -a
./cf login -a api.cloud.service.gov.uk
```

## Discussion
The cli is delivered as an all in one binary, you will need to move this into your path or create an alias in the shell to point to the correct binary.

## See also

- [cf cli][1]

[1]: https://github.com/cloudfoundry/cli#downloads
