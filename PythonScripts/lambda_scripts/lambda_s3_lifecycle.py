import boto3
from datetime import datetime
s3 = boto3.resource('s3')


bucket = s3.Bucket('pooja.1')
bucketLifeCycle = s3.BucketLifecycle('pooja.1')

def lambda_handler(event, context):
    response = bucketLifeCycle.put(LifecycleConfiguration={'Rules': [
                {
                    'ID': 'clean',
                    'Status': 'Enabled',
                    'Prefix': '*',
                    'AbortIncompleteMultipartUpload': {
                        'DaysAfterInitiation': 1
                }
            }    
        ]
    }
) 
