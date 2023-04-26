# sysmon
background process monitoring

simple shell script to check various daemon processes and restart them if necessary

# config

standard JSON array with the following fields:
- name

  name of the service.
- run

  shell command to start the service.
- check

  command to check if service is healthy. return value should be 0 if the service is running and healthy.

# example

```
[
  {
    "name": "<NAME>",
    "run": "<START-COMMAND>",
    "check": "<CHECK-COMMAND>"
  },
  {
    "name": "telemetry",
    "run": "setsid su pi -c /home/pi/telemetry.sh >/dev/null 2>&1 < /dev/null &",
    "check": "ps aux|grep -q \"[t]elemetry.sh\""
  }
]
```
