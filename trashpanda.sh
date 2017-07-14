 #!/bin/bash

trash=/home/$USER/.local/share/Trash  # default path of the Trash folder
create_log=false
idtime=30s       # default idle time
TTL=$((10*60))   # default time to life (TTL)

for i in "$@" ; do
    if [[ $i == *"log"* ]]; then
        create_log=true
    fi
    
    if [[ $i == *"remove-logs"* ]]; then
      rm -f *trashpanda.log
      echo "all trashpanda logs removed"
    fi
    
    if [[ $i == "-ttl="* ]]; then
        ttl=$(echo $i | cut -d= -f2)
    fi
    
    if [[ $i == "-idtime="* ]]; then
        idtime=$(echo $i | cut -d= -f2)
    fi
done

log_dir="logs"

if [ ! -d "logs" ]; then
  mkdir $log_dir
fi


if [ $create_log = true ]; then
  creatation_date=$(date +"%Y-%m-%d-%H:%M:%S")
  logfile=$log_dir/$creatation_date-$$-trashpanda.log
  echo "trashpanda logfile created on $creatation_date with process id $$" >> $logfile
  
  echo "TIME: $idtime" >> $logfile
  echo "TTL: $TTL"   >> $logfile
fi


while [[ true ]]; do
  now=$(date +%s) # current time (in seconds since EPOCH)

  for ext_filename in $trash/info/*; do  
    filename=$(basename "$ext_filename")
    extension="${filename##*.}"
    filename="${filename%.*}"
    full_name=$filename.$extension
    
    if [[ "$filename" == "*" ]]; then
      continue
    fi
    
    del_date=$(tail -n 1 "$ext_filename" | cut -d= -f2)
    erased=$(date --date=$del_date +%s)
    
    if [[ $(($now-$erased)) -ge $TTL ]]; then
        if [ $create_log = true ]; then
          echo "$filename was erased on $(date)" >> $logfile
          echo $(tail -n 2 "$ext_filename") >> $logfile
          echo "" >> $logfile
        fi
        
        rm -rf "$trash/files/$filename"
        rm -rf "$trash/info/$full_name"
    fi
  done
  
  for ext_filename in $trash/files/*; do
    filename=$(basename "$ext_filename")
    
    if [[ "$filename" == "*" ]]; then
      continue
    fi
  
    if [[ -d "$ext_filename" ]]; then
        if [ $create_log = true ]; then
          echo "directory $filename was erased on $(date)" >> $logfile
          echo "" >> $logfile
        fi
        
        rm -rf "$ext_filename"
    fi
    
  done

  #sleep for $idtime
  sleep $idtime
done
