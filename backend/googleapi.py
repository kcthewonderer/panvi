
# Imports the Google Cloud client library
from google.cloud import vision
import os
from google.api_core.exceptions import ServiceUnavailable
import io
import time
from requests.exceptions import ConnectionError
import re

'''os.environ["http_proxy"] = "http://127.0.0.1:7890"
os.environ["https_proxy"] = "http://127.0.0.1:7890"
'''
# Set GOOGLE_APPLICATION_CREDENTIALS in your environment to a service-account key path (not committed).

WORD = re.compile(r"\w+")

def run_quickstart() -> vision.EntityAnnotation:
    
    """Provides a quick start example for Cloud Vision."""

    # Instantiates a client
    client = vision.ImageAnnotatorClient()

    # The URI of the image file to annotate
    file_uri = "gs://cloud-samples-data/vision/ocr/sign.jpg"

    image = vision.Image()
    image.source.image_uri = file_uri

    # Performs label detection on the image file
    response = client.label_detection(image=image)
    labels = response.label_annotations

    print("Labels:")
    for label in labels:
        print(label.description)

    return labels

run_quickstart()

'''from google.cloud import vision
from google.api_core.exceptions import ServiceUnavailable
import io
import time
from requests.exceptions import ConnectionError

def retry_on_connectionerror(image_path, max_retries=5):
  retries = 0
  while retries < max_retries:
    try:
      detect_objects_and_text(image_path)
      break
    except ConnectionError:
      retries += 1
  raise Exception("Maximum retries exceeded")



def detect_objects_and_text_with_retry(image_path, retries=3, delay=5):
    for attempt in range(retries):
        try:
            detect_objects_and_text(image_path)
            break  # Exit loop if successful
        except ServiceUnavailable as e:
            print(f"Service unavailable, attempt {attempt + 1}/{retries}. Retrying in {delay} seconds...")
            time.sleep(delay)
    else:
        raise Exception(f"Failed after {retries} attempts")

# Set up the Vision client
client = vision.ImageAnnotatorClient()

# Path to your image file
image_path = "darknet/data/pickel_jar.png"

def detect_objects_and_text(image_path):
    # Read the image file into memory
    with io.open(image_path, 'rb') as image_file:
        content = image_file.read()
    
    # Construct the image instance for the Vision API
    image = vision.Image(content=content)
    
    # Object Detection
    objects = client.object_localization(image=image).localized_object_annotations
    print("Detected objects:")
    for object_ in objects:
        print(f"{object_.name} (Confidence: {object_.score})")
        # Print the bounding polygon for each object
        for vertex in object_.bounding_poly.normalized_vertices:
            print(f" - ({vertex.x}, {vertex.y})")
    
    # Label Detection (identifies general objects, concepts, or scenes)
    labels = client.label_detection(image=image).label_annotations
    print("\nDetected labels:")
    for label in labels:
        print(f"{label.description} (Confidence: {label.score})")
    
    # Text Detection (OCR)
    response = client.text_detection(image=image)
    texts = response.text_annotations
    print("\nDetected text:")
    for text in texts:
        print(f"Text: {text.description}")
        # Print bounding polygon for each detected text
        for vertex in text.bounding_poly.vertices:
            print(f" - ({vertex.x}, {vertex.y})")
    
    if response.error.message:
        raise Exception(f"{response.error.message}")

# Run the function
detect_objects_and_text(image_path)'''
