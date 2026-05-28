import urllib.request
import urllib.parse
from urllib.error import URLError

boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'
body = (
    '--' + boundary + '\r\n'
    'Content-Disposition: form-data; name="reqtype"\r\n\r\n'
    'fileupload\r\n'
    '--' + boundary + '\r\n'
    'Content-Disposition: form-data; name="fileToUpload"; filename="test.jpg"\r\n'
    'Content-Type: image/jpeg\r\n\r\n'
    'testdata\r\n'
    '--' + boundary + '--\r\n'
)

req = urllib.request.Request('https://catbox.moe/user/api.php', data=body.encode('utf-8'))
req.add_header('Content-Type', f'multipart/form-data; boundary={boundary}')
req.add_header('User-Agent', 'Mozilla/5.0')
try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode())
except Exception as e:
    print(e)
