function build {
  JS_file=${Scripts_DIR}/commands/tasks/unicom/unicom.js
  Taskarray=(`cat ${JS_file} | sed '/\/\*\*\*/,/\*\*\*\//d' | sed '/\/\*/,/\*\//d'|sed '/\/\//d' | grep -oE "\"[a-z A-Z0-9]+\""| cut -f2 -d\"`)
  for ((i=0;i<${#Taskarray[@]};i++))
  do
    Line=$(sed -n "/\"${Taskarray[$i]}\"/=" ${JS_file})
    printf "#####($(($i+1)))"
    cat ${JS_file} | sed -n $(($Line-3)),$(($Line-2))p | grep \/\/ | sed 's/[ \t]*//g'|sed 's/[\/\/\t]*//g'|sed 's/^/#&/g'
    if [ $i>12 ];then 
      min=$(($i*5-$i/12*60))
      hour=$((8+$i/12))
    else 
      min=$(($i*5))
      hour=8
    fi
    echo "$min $hour * * * bash u ${Taskarray[$i]}"
  done
}
echo "生成crontab.sh.sample文件..."
rm -rf ${ASMShell_DIR}/config/crontab.sh.sample
build>${ASMShell_DIR}/config/crontab.sh.sample
echo "0 15 * * *  bash <(bash all)">>${ASMShell_DIR}/config/crontab.sh.sample
echo "0 */4 * * * bash start">>${ASMShell_DIR}/config/crontab.sh.sample
echo "0 0 */3 * * rm -rf ${ASMShell_DIR}/logs/*.log">>${ASMShell_DIR}/config/crontab.sh.sample


echo "备份原配置..."
cp -f ${ASMShell_DIR}/config/crontab.sh ${ASMShell_DIR}/config/crontab.sh.bak
echo "生成新配置..."
cp -f ${ASMShell_DIR}/config/crontab.sh.sample ${ASMShell_DIR}/config/crontab.sh
echo "执行新配置..."
/usr/bin/crontab ${ASMShell_DIR}/config/crontab.sh