#!/bin/bash 
qrcode()
{

		qrcode-terminal "http://"$(ip addr show wlp3s0 |grep -Eo $ipregex |head -n1 )":9000/"
		cd ~/.webshare && python3 -m http.server 9000 
		( ping -c 3 localhost.run >/dev/null  2>&1  && ssh  -i ~/tempkey  -R 80:localhost:9000 localhost.run  ) || echo 'no network tunnel failed'
}
share()

{
		if [[ "$1" = "f" ]]
		then 
		echo "success $1"

		[[ ! -d ~/.webshare   ]] && mkdir -p ~/.webshare 
		#cp  -r --reflink "$2" ~/.webshare/ 
		path="$(realpath "$2")"
		ln -s "$path" "/home/sanbotbtrfs/.webshare/"
		qrcode
elif [[ "$1" = "s" ]]
then
		if [[ ! -z "$3"   ]];
		then 
				path="$( find "$2"  -regextype egrep -regex "$3" |fzf  )"
		else 

				path="$( find "$2"   |fzf  )"
		fi 
		path="$(realpath "$path")"
		ln -s "$path" "/home/sanbotbtrfs/.webshare/"
		qrcode
else
		 error
fi 
}

cleanup()
{
		echo 'cleanup operation '
rm -vrf ~/.webshare/*
}
error()
{
echo 'usage share [s/f] <filename/dir> <regex optional>'

}
trap cleanup 1 2 3 6 14 15  ;
 [[ ! $# -lt 2  ]] && share "$1" "$2" "$3" || error 
