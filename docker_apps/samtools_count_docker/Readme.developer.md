# samtools_count_docker Developer Readme

## Preparing docker snapshot from within ttyd app

### docker pull an image from a registry to a container on our machine
```
docker pull quay.io/biocontainers/samtools:1.15.1--h6899075_1
```

### Saving a snapshot file to your project
```
docker save quay.io/biocontainers/samtools:1.15.1--h6899075_1 -o samtools.tar.gz
dx upload samtools.tar.gz
```

## Building applet

To build this applet run the following code (you should be in the directory containing samtolls_count_apt folder):

```
dx build samtools_count_docker
```

## Running this app with additional computational resources

This app has the following entry points:

* main

When running this app, you can override the instance type to be used by
providing the ``systemRequirements`` field to ```/applet-XXXX/run``` or
```/app-XXXX/run```, as follows:

    {
      systemRequirements: {
        "main": {"instanceType": "mem2_hdd2_x2"}
      },
      [...]
    }

See <a
href="https://documentation.dnanexus.com/developer/api/running-analyses/io-and-run-specifications#run-specification">Run
Specification</a> in the API documentation for more information about the
available instance types.
