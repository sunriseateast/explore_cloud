import boto3
import time
from pprint import pprint
volume=[]
def lambda_handler(event, context):
    ec2_console=boto3.client("ec2")
    ec2_console.create_volume(AvailabilityZone='ap-south-1b',Size=10, VolumeType='gp3') ###create volume
    
    ebs_console=ec2_console.describe_volumes() ### adding volume to list by using describe method
    for i in ebs_console['Volumes']:
        volume.append(i['VolumeId'])
    time.sleep(5)
    ec2_console.attach_volume(      ### Attach volume to ec2 instance
        Device='/dev/sdh',
        InstanceId='i-0043dfb37f0105ab8',
        VolumeId=volume[-1]
    )
    handle=" "
    sqs_console=boto3.client("sqs")
    sqs_recieve=sqs_console.receive_message(QueueUrl="https://sqs.ap-south-1.amazonaws.com/542662511196/demo-queue")
    for i in sqs_recieve['Messages']:
        handle=i['ReceiptHandle']
    sqs_console.delete_message(QueueUrl="https://sqs.ap-south-1.amazonaws.com/542662511196/demo-queue",ReceiptHandle=handle)