from google.cloud import firestore
from flask import Flask
import json, os

db = firestore.Client(project='hf-crc-001')
doc = db.collection(u'counter_collection').document(u'counter_doc')

def get_counter():
  return doc.get().to_dict()['counter']

def increment_counter():
  counter = get_counter() + 1
  doc.update({u'counter': counter})
  return counter


app = Flask(__name__)

@app.route("/")
def update_counter():
  headers = {
    'Access-Control-Allow-Origin': '*'
  }
  res = increment_counter()
  return (json.dumps({u'counter':res}), 200, headers) 

@app.route("/hello")
def uptime_check():
  headers = {
    'Access-Control-Allow-Origin': '*'
  }
  return (json.dumps("Hello from the cloud!"), 200, headers) 

if __name__ == "__main__":
	app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
