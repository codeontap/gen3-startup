Varibles to be passed to command line:

* ecs_cluster
* ecs_loglevel
* ecs_log_driver

To pass them --extra-vars argument is used:

`ansible-playbook site.yml -i hosts --extra-vars "ecs_cluster=cluster ecs_loglevel=leglevel ecs_log_driver=log_driver"`
