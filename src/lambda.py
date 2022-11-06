import json
import requests


ENDPOINT = "https://randomuser.me/api"

def handler(event, context):
  try:
    res = requests.get(ENDPOINT)
  except requests.exceptions.RequestException as e:
    print(e)
  else:
    print(json.dumps(res.json(), indent=2))


if __name__ == '__main__':
  event = {}
  context = {}
  handler(event, context)