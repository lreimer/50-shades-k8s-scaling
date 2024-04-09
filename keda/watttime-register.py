import requests
register_url = 'https://api2.watttime.org/v2/register'
params = {'username': 'lreimer',
         'password': 'green-k8s',
         'email': 'mario-leander.reimer@qaware.de',
         'org': 'QAware GmbH',}
rsp = requests.post(register_url, json=params)
print(rsp.text)
