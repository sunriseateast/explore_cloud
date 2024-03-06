#!/bin/bash
remain=$(df -h -t xfs --output=pcent | tail -1 | sed 's/.$//')
folder=$(ls | grep "volume")
if [ $remain -eq 20 ]
then
        aws sqs send-message --queue-url https://sqs.ap-south-1.amazonaws.com/542662511196/demo-queue --message-body="storage is full"
        sleep 20
        if [ "$folder" == "volume" ]
        then
                volume=$(lsblk | tail -1 | awk '{print $1}')
                part=$(echo $volume"1")
                echo $volume
                echo $part
                echo -e "n\np\n1\n\n\nt\n8e\nw" | fdisk /dev/"$volume" > /dev/null 2>&1
                vgextend vgdemo /dev/"$part"
                lvextend -l +2559 /dev/vgdemo/bydemo1
                xfs_growfs /dev/vgdemo/bydemo1
        else
                volume=$(lsblk | tail -1 | awk '{print $1}')
                part=$(echo $volume"1")
                echo $volume
                echo $part
                echo -e "n\np\n1\n\n\nt\n8e\nw" | fdisk /dev/"$volume" #> /dev/null 2>&1
                vgcreate vgdemo /dev/"$part" #> /dev/null 2>&1
                lvcreate -l 100%FREE -n bydemo1 vgdemo #> /dev/null 2>&1
                mkfs -t xfs /dev/vgdemo/bydemo1 #> /dev/null 2>&1
                mkdir volume
                mount /dev/vgdemo/bydemo1 volume
        fi
fi