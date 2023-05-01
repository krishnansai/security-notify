string=$(nmap -vvv localhost | awk '/open/{print $1 "\n"}')

number=$(echo $string | grep -o '[0-9]*')
num=$(echo $number | cut -d' ' -f2)

SLACK_WEBHOOK="https://hooks.slack.com/services/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"
SLACK_CHANNEL=${SLACK_CHANNEL-"testing"}
SLACK_USERNAME=${SLACK_USERNAME-"sai"}

[ -z $SLACK_WEBHOOK ] && { echo "The SLACK_WEBHOOK is not set!"; exit 1; }

# server status data

HOSTNAME=`hostname`
HOSTIP=`hostname -I | sed -r 's/(\S+) (\S+)/\1, \2/g'`
ROUTES=`ip route list scope global`
UPTIME=`uptime`
DISK=`df -hT /`
MEMORY=`free -h`

# sending the message

statusMessage() {
    echo -e ":black_small_square: *${HOSTNAME}* - ${HOSTIP}\n"
    echo -e "_Uptime:_\n\`\`\`${UPTIME}\`\`\`"
    echo -e "_Memory:_\n\`\`\`${MEMORY}\`\`\`"
    echo -e "_Disk:_\n\`\`\`${DISK}\`\`\`"
    echo -e "_Routes:_\n\`\`\`${ROUTES}\`\`\`"
}



PAYLOAD="{\"channel\": \"#${SLACK_CHANNEL}\", \"username\": \"${SLACK_USERNAME}\", \"text\": \"`statusMessage`\"}"
if [[ $num -eq 80 ]]
then
  echo "port 80 has been opened notify"
  curl -X POST --data-urlencode "payload=$PAYLOAD" $SLACK_WEBHOOK
  sleep 60
  echo "port has been automatically close"
  service apache2 stop
fi
