#!/bin/sh

# size of swapfile
swapsize=$1
swapfile="/swapfile"

# does the swap file already exist?
ls ${swapfile} > /dev/null 2>&1

# if not then create it
if [ $? -ne 0 ]; then
  echo 'Swapfile not found. Adding swapfile.'
  dd if=/dev/zero of=${swapfile} bs=1M count=${swapsize}
  chmod 600 ${swapfile}
  mkswap ${swapfile}
  swapon ${swapfile}
else
  echo 'swapfile found. No changes made.'
fi


# does the swap file already exist?
grep -q "${swapfile}" /etc/fstab

# if not then create it
if [ $? -ne 0 ]; then
  echo 'No swap entry in /etc/fstab found. Add swap entry to /etc/fstab.'
  echo "${swapfile} none swap defaults 0 0" >> /etc/fstab
else
  echo 'Swap entry in /etc/fstab found. No changes made.'
fi

# output results to terminal
df -h
cat /proc/swaps
cat /proc/meminfo | grep Swap
