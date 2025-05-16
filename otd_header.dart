Map<String, String> myHeader() {
  Map<String, String> header = {
    'accept': '*/*',
    'Authorization':
        'Bearer abc',
    'Content-Type': 'application/xml'
  };

  return header;
}
