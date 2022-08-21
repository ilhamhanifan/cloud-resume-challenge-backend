from google.cloud import firestore
import json 

db = firestore.Client.from_service_account_json('./terraform-sa-key.json')
doc = db.collection(u'counter-collection').document(u'counter-id')

def get_counter():
  return doc.get().to_dict()['counter']['count']

def update_counter():
  count = get_counter() + 1
  doc.update({u'counter':{u'count': count}})
  return count

def firestore(request):
  headers = {
      'Access-Control-Allow-Origin': '*'
  }
  res = update_counter()
  return (json.dumps({u'counter':{u'count': res}}), 200, headers) 