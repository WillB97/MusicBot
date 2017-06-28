#! /bin/bash
cd $HOME/MusicBot

# MusicBot options
# -f		Open foreground and tee
# -b		Open background
# -s		view song list
# -c/.	view command log
# -e		stop background

function usage() {
	echo "$0 [-hfbscer]"
	echo "  -h  Display this message."
	echo "  -f  Open MusicBot in a foreground process and tee output to CMDlog"
	echo "  -b  Open MusicBot in a background process and redirect output to CMDlog"
	echo "  -s  View the list of played music"
	echo "  -c  View the output log (implict if no options specified)"
	echo "  -e  End MusicBot running in a background process"
	echo "  -r  Close running bots and start a background bot"
}

if [ "$#" -eq "0" ]; then tail -f CMDlog; exit 0; fi
while getopts :hfbscer o
do	#echo "Arg: $o $OPTARG"
	case "$o" in
	h)	usage
		exit 1;;
	f)	if [ ! -f ".save_pid" ]; then
			python3 run.py | tee -a CMDlog 2>&1
			exit 0
		else
			echo "MusicBot is already running in the background"
			exit -1;
		fi;;
	b)	if [ ! -f ".save_pid" ]; then
			nohup python3 run.py >> CMDlog 2>&1 &
			echo $! > .save_pid
			echo "MusicBot started"
			exit $!;
		else
			echo "MusicBot is already running in the background"
			exit -1;
		fi;;
	s)	tail -f SongLog.csv;;
	c)	tail -f CMDlog;;
	e)	if [ -f ".save_pid" ]; then
			kill $(cat .save_pid)
			rm .save_pid
			echo "MusicBot stopped"
			exit 0
		else
			echo "No record of MusicBot running in the background"
			exit -1
		fi;;
	r)	if [ -f ".save_pid" ]; then
			kill $(cat .save_pid)
			rm .save_pid
			echo "MusicBot stopped"
		else
			echo "No record of MusicBot running in the background"
		fi
		ps -xa | grep python | sed '/^.*\(grep\).*$/d'
		nohup python3 run.py >> CMDlog 2>&1 &
		echo $! > .save_pid
		echo "MusicBot started"
		exit $!;;
	\?)	echo "Invalid option: -$OPTARG"
		usage
		exit 1;;
	esac
done
