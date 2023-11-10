#!/bin/bash
# set -x

prBar=0
allNeedFlow=$2
sesName="Jup$USER"

function showProgBar {
  local bar=""
  local per=$(($prBar * 100 / $allNeedFlow))
  local i
  for ((i=0; i <= 10; i++))
  do
    if [[ i -le $(($per / 10)) ]]
    then
      bar="${bar}#"
    else
      bar="${bar}_"
    fi
    # echo $bar
  done

  bar="\nProgress: '${bar}'  (${per}%)\n"

  echo -e $bar
}

function genToken {
  val=$(date)
  local token=$(echo "${1}${val}" | md5sum -z | head -c 32)
  echo $token
}

function createStartStm { # Формирует команду для запуска нового окна tmux
  # $1-папка среды
  # $2-токен
  # $3-файл логов юпитера
  local statement="cd $1;
  source ./venv/bin/activate;
  jupyter notebook
  --ServerApp.root_dir=${1}
  --ServerApp.open_browser=0
  --ServerApp.token=${2}
  --allow-root
  |& tee ${1}/${3}"

  # 2>${1}/${3}"

  echo $statement
}

function buildAppDir { # Создает папку и загружает в нее вирт. среду
  # $1 - имя директории окружений
  # $2 - номер нового окружения
  local newDir=$1/dir$2
  mkdir $newDir

  newDir=$newDir/venv
  virtualenv $newDir 1> /dev/null

  source $newDir/bin/activate
  pip install jupyter 1> /dev/null 2>/dev/null
  deactivate
  return 0
}

function writeEnvInfo {
  # Выводит информацию об окружении
  echo "Started env ${1}:"
  echo "token: ${2}; Port: ${3}"
}

function getPort {
  # Ждет создание файла
  # $1 - путь с именем файла
  local port=-1
  # while [[ $port -eq -1 ]]
  # do
  local i
  for ((i=0; i < 10; i++))
  do
    sleep 2
    if [[ -s $1 ]]
    then
      port=$(grep -E http:// $1 | tail -n 1 | grep -Eo :[[:digit:]]\+/ | grep -Eo [[:digit:]]\+)
      break
    # else
      # echo "Файл Jupyter c указанием порта еще не создан"
    fi
  done

  # tail -n100 $1

  if [[ $port -eq -1 ]]
  then
    echo "Порт не определен"
  else
    echo $port
  fi
}

function startJup {
  # $1 - имя основной директории
  # $2 - номер юпитера
  # $3 - создаем сессию ses или окно win

  local token=$(genToken dir$2)
  buildAppDir $1 $2

  # имя папки для логов юпитера
  local fileErrName="jStdErr${2}.txt"

  local startStm=$(createStartStm $1/dir$2 $token $fileErrName)

  if [[ $3 = "ses" ]]
  then # если нужно запустить сессию tmux
    tmux new -d -s $sesName -n $2 "$startStm"
  else # если нужно запустить окно tmux
    tmux neww -d -n $2 -t $sesName "$startStm"
  fi

  #определяем порт
  local jPort=$(getPort $1/dir$2/$fileErrName)

  # Выводим информацию об окружении
  writeEnvInfo $2 $token "$jPort"
}

# СОЗДАЕМ ПОТОКИ
function createJupNote {
  local mainDir="$HOME/JupDir"
  local dirNum=0
  local newDirCount=$1
  echo "Создание..."

  showProgBar

  if ! [[ -d $mainDir ]]
  then
    # если директория не существует
    # echo "Папки $mainDir не существует"
    mkdir -p $mainDir
  else
    # Иначе находим наибольший номер папки
    dirNum=$(ls -1 $HOME/JupDir | cut --characters=4- | sort -n | tail -n 1)
    dirNum=$(( $dirNum + 1 ))
  fi

  if !(tmux ls 2> /dev/null 1> /dev/null)
  then
    # если tmux не запущен, то запускаем новую сессию
    startJup $mainDir $dirNum "ses"

    dirNum=$(( $dirNum + 1 )) # увеличиваем номер новой директории
    newDirCount=$(( $newDirCount - 1 )) # уменьшаем количество создаваемых окон

    prBar=$(($prBar + 1)) # увеличиваем значение индикатора завершения
    # echo "Увеличили $prBar"
    showProgBar
  fi

  local i
  for (( i=0; i < $newDirCount; i++ ))
  do # Создаем окружения
    startJup $mainDir $dirNum "win"

    dirNum=$(( $dirNum + 1 )) # увеличиваем номер новой директории
    prBar=$(($prBar + 1)) # увеличиваем значение индикатора завершения
    # echo "Увеличили $prBar"
    showProgBar
  done

  echo "--- Окружения созданы ---"
}

function stopFlow {
  if (tmux ls 2> /dev/null 1> /dev/null)
  then
    if (tmux killw -t $sesName:$1 2> /dev/null)
    then
      echo "Окружение $1 остановлено"
    else
      echo "Окружение $1 не существует"
    fi
  else
    echo "Ни одно окружение не запущено"
  fi
}

function stopAll {
  if (tmux kill-session -t $sesName 2> /dev/null)
    then
      echo "Все окружения остановлены"
  else
    echo "Ни одно окружение не запущено"
  fi
}

if [[ $# -eq 2 ]]
then
  if [[ $1 = "start" ]]
  then
    echo "Получен параметр $1. Создаю $2 новых окружений"
    echo "-----------------------------------------------"

    createJupNote $2
  elif [[ $1 = "stop" ]]
  then
    stopFlow $2
  fi
elif [[ $# -eq 1 ]] && [[ $1 = "stop_all" ]]
then
  stopAll
else
  echo "$1 нет такой команды"
fi
