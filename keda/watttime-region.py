import requests
from requests.auth import HTTPBasicAuth

login_url = 'https://api2.watttime.org/v2/login'
token = requests.get(login_url, auth=HTTPBasicAuth('lreimer', 'green-k8s')).json()['token']

region_url = 'https://api2.watttime.org/v2/ba-from-loc'
headers = {'Authorization': 'Bearer {}'.format(token)}

# Sweden
params = {'latitude': '62.84', 'longitude': '17.55'}
rsp=requests.get(region_url, headers=headers, params=params)
print(rsp.text)

# Norway
params = {'latitude': '65.39', 'longitude': '17.83'}
rsp=requests.get(region_url, headers=headers, params=params)
print(rsp.text)