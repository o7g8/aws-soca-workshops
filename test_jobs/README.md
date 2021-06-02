# PBS: Test jobs

In the directory you find jobs for smoke test of the PBS and custom AMI:

- `hello_world.que` - single-node job printing "Hello World" to `hello_world.qlog`
- `hello_world_c5large.que` - same job, just running on c5.large. Prints "Hello World" into `hello_world_c5large.qlog`
- `hello_world_custom_ami.que` - same job, running with Aerospace AMI (set your own AMI id!!). Prints "Hello World" into `hello_world_custom_ami.qlog`