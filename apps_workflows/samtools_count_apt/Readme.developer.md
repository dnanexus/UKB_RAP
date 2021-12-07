# samtools_count_apt Developer Readme

## Building applet

To build this applet run the following code (you should be in the directory containing samtolls_count_apt folder):

```
dx build samtolls_count_apt
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
