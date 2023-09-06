#!/bin/bash

# Get a list of failed jobs created in the last 2 days
jobs=$(dx find jobs --json --state failed --created-after=-2d --num-results 1000)

# Loop through each job ID
for job_id in $(echo "$jobs" | jq -r '.[].id'); do
  # Describe the job and look for the termination message
  job_description=$(dx describe $job_id --verbose)
  termination_msg="SpotInstanceInterruption"

  if echo "$job_description" | grep -q "$termination_msg"; then
    # If the termination message is found, print the job ID
    echo $job_id
  else
    echo "Not found"
  fi

done
