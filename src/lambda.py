import json
import requests


ENDPOINT = "https://randomuser.me/api"

def handler(event, context):
  try:
    res = requests.get(ENDPOINT)
  except requests.exceptions.RequestException as e:
    print(e)
  else:
    print(res)
