import pprint
import veryfi
import pandas as pd



import os
import sys

# Credentials come from the environment (see backend/.env.example). Never hard-code them.
client_id = os.environ["VERYFI_CLIENT_ID"]
client_secret = os.environ["VERYFI_CLIENT_SECRET"]
username = os.environ["VERYFI_USERNAME"]
api_key = os.environ["VERYFI_API_KEY"]

client = veryfi.Client(client_id, client_secret, username, api_key)

categories = ["Travel", "Airfare", "Lodging", "Job Supplies and Materials", "Grocery"]
json_result = client.process_document(sys.argv[1], categories)  # path to a receipt image

pprint.pprint(json_result)

