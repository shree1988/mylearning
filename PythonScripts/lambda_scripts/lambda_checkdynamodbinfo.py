import json
import boto3
from datetime import datetime, timedelta

today = datetime.now()
date_90_days_ago = str(datetime.date(datetime.now()) + timedelta(days=90))
date_60_days_ago = str(datetime.date(datetime.now()) + timedelta(days=60))
date_30_days_ago = str(datetime.date(datetime.now()) + timedelta(days=30))

dynamodb = boto3.resource('dynamodb')

def sender(certificatetype,days,certificatename,ExpirationDate,env,info):
    
    from botocore.exceptions import ClientError
    SENDER = "raja.b.reddy@capgemini.com"
    RECIPIENT = "raja.b.reddy@capgemini.com"
    AWS_REGION = "us-east-1"
    SUBJECT = " " +info+ " : " +certificatename+ "Certificate : " +days+ " remaining to expire " +certificatetype+ " Type"
    BODY_HTML = """<html>
    <head></head>
    <body>
      <p>Certificate Name="""+certificatename+"""</p>
      <p>End of certificate ="""+ExpirationDate+"""</p>
      <p>Certificate Type   ="""+certificatetype+"""</p>
      <p>Environment        ="""+env+"""</p>
    </body>
    </html>
                """          
    CHARSET = "UTF-8"

    client = boto3.client('ses',region_name=AWS_REGION)
    try:
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT
                    ,
                },
            },
            Source=SENDER,
        )
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])

def lambda_handler(event,context):  
    table = dynamodb.Table('CertificatesData')
    response = table.scan()
    for rsp in response['Items']:
        certDate = rsp['Expiry_Date']
        
        datetime_object = datetime.strptime(certDate, '%Y-%m-%d')
        
        
        
        datetime90 = datetime.strptime(date_90_days_ago, '%Y-%m-%d')
        datetime60 = datetime.strptime(date_60_days_ago, '%Y-%m-%d')
        datetime30 = datetime.strptime(date_30_days_ago, '%Y-%m-%d')
        days = datetime_object -today
        strdate = str(days)
        day = strdate.split(',')
        info = ['Information', 'Alert']
        
        if   datetime_object > datetime60 and datetime_object < datetime90:
             print("the date is between 90-60 {} are remaining to expire the certificate".format(day[0]))
             #print(sender(rsp['Certificate_Type'],day[0],rsp['CertificateName'],rsp['Expiry_Date'],rsp['Environment_Type'],info[0]))
        elif datetime_object > datetime30 and datetime_object < datetime60:
             print("the date is between 60-30 {} are remaining to expire the certificate".format(day[0]))
             #print(sender(rsp['Certificate_Type'],day[0],rsp['CertificateName'],rsp['Expiry_Date'],rsp['Environment_Type'],info[0]))
        elif datetime_object <= datetime30 and datetime_object >= today :
             print("the date is less than 30 {} are remaining to expire the certificate".format(day[0]))
             print(sender(rsp['Certificate_Type'],day[0],rsp['CertificateName'],rsp['Expiry_Date'],rsp['Environment_Type'],info[1]))
        else:
             print("We have enough time to renew certificate {} are remaining to expire the certificate".format(day[0]))

