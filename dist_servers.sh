#!/bin/bash

source  ~/.bash_profile

#listen directory
src_dispatcher=/home/users/lujunxu/xxx/
server_log=/home/users/lujunxu/myshell/log/rsync.log
error_log=/home/users/lujunxu/myshell/log/rsync_err.log

declare -A SUB_1=(["src"]="/xxx/" ["des"]="/xxx/" ["ip"]="host1" ["user"]="lujunxu")
declare -A SUB_2=(["src"]="/xxx/" ["des"]="/xxx/" ["ip"]="host2" ["user"]="lujunxu")
declare -A SUB_3=(["src"]="/xxx/" ["des"]="/xxx/" ["ip"]="host3" ["user"]="lujunxu")
declare -A SUB_4=(["src"]="/xxx/" ["des"]="/xxx/" ["ip"]="host4" ["user"]="lujunxu")
declare -A SUB_5=(["src"]="/xxx/" ["des"]="/xxx/" ["ip"]="host5" ["user"]="lujunxu")
declare -A SUB_6=(["src"]="/xxx/" ["des"]="/xxx/" ["ip"]="host6" ["user"]="lujunxu")

MAIN_ARRAY=(
  "${SUB_1[*]}"
  "${SUB_2[*]}"
  "${SUB_3[*]}"
  "${SUB_4[*]}"
  "${SUB_5[*]}"
  "${SUB_6[*]}"
)

#aappend timestamp
log_stderr() {
    #gawk -v pref="$1" '{print pref":", strftime("%F %T", systime()), $0}' >&2
    gawk -v pref="$1" '{print pref":", strftime("%F %T", systime()), $0}' >> $error_log
}

rsync_multi(){
echo "COUNT: " ${#MAIN_ARRAY[@]}
for key in ${!MAIN_ARRAY[@]}; do
    #echo -e "key is $key"
    IFS=' ' read -a val <<< ${MAIN_ARRAY[$key]}
    #echo "VALUE: " ${val[@]}
    if [[ ${#val[@]} -gt 3 ]]; then
            src_rsync=${val[0]}
            echo -e "src_rsync is $src_rsync"
            use=${val[1]}
            echo -e "use is $use"
            des=${val[2]}
            echo -e "des is $des"
            ip=${val[3]}
            echo -e "ip is $ip"
            echo -e "now the file begin rsync ${file}:"
            echo -e "host=$ip" >> $server_log
            rsync -ahvz --exclude  '*.out'  --exclude  '*.log' --exclude  '*.swp'  --exclude  '*.err' --exclude  '*.ago' --exclude  '*.temp' --exclude  '*.pyc' --log-file=$server_log  --delete --progress ${src_rsync} ${use}@${ip}:${des}  2> >(log_stderr "[$ip]")  &&
            echo -e "now the file is ${file} was rsynced!"
            echo -e "end host=$ip rsync" >> $server_log
        echo -e "host $ip end---------------------------------------------------------------------------"

    fi
done
}

function end_one_loop(){
    echo "" >> $error_log
}





E_FILES='^.*\.(log|out|swp)$'
RSYNC_EXCLUDE="--exclude  '*.out'  --exclude  '*.log' --exclude  '*.swp'"
echo $RSYNC_EXCLUDE

inotifywait -mrsq  --exclude $E_FILES --timefmt '%d/%m/%y %H:%M' --format  '%T %w%f' \
 -e close_write,delete,move,create \
${src_dispatcher} \
| while read  file
        do
			rsync_multi
			end_one_loop
        done
