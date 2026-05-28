import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Testing Catbox...');
  
  // Create a dummy image
  final dummyBytes = List<int>.generate(100, (i) => i);
  
  try {
    final request = http.MultipartRequest("POST", Uri.parse("https://catbox.moe/user/api.php"));
    request.fields['reqtype'] = 'fileupload';
    request.fields['userhash'] = '';
    
    // Add user agent
    // request.headers['User-Agent'] = 'Mozilla/5.0';
    
    final multipartFile = http.MultipartFile.fromBytes(
      'fileToUpload',
      dummyBytes,
      filename: "test.jpg",
    );
    request.files.add(multipartFile);

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('Status: \${response.statusCode}');
    print('Body: \$responseBody');
  } catch (e) {
    print('Error: \$e');
  }
}
