from google.cloud import vision
from google.oauth2 import service_account
import os
import sys
from google.api_core import retry, exceptions



# Path to a Google Cloud service-account key, supplied via the environment (never committed).
credentials = service_account.Credentials.from_service_account_file(os.environ['GOOGLE_APPLICATION_CREDENTIALS'])
client = vision.ImageAnnotatorClient(credentials=credentials)

with open(sys.argv[1],'rb') as image_file:  # path to a food photo
    content = image_file.read()

image = vision.Image(content=content)
#response = client.label_detection(image=image)

custom_retry = retry.Retry(
    initial=1.0,
    maximum=10.0,
    multiplier=2.0,
    deadline=30.0,
    predicate=retry.if_exception_type(
        exceptions.ServiceUnavailable,
        exceptions.DeadlineExceeded)
)

response = client.label_detection(image=image, retry=custom_retry)

for label in response.label_annotations:
    print(label.description, label.score)