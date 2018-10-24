#! /bin/bash
# cron-entry : 0 0,6,12,18 * * * /bin/recovery-Job.sh
/bin/recovery.sh -d -b 2>&1 > /log/"recovery-Job_"$(date +%Y-%m-%d_%H%M%S)
