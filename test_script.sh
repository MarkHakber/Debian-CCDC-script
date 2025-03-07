#!/bin/bash

echo "✅ Script is running on Debian"
echo "Current user: $(whoami)"
echo "OS Info:"
cat /etc/os-release

# Create a log file
echo "Test script ran successfully on $(date)" > test_log.txt
echo "📄 Log file 'test_log.txt' created."

# Verify execution
ls -l test_log.txt

# Minor update to force GitHub refresh
