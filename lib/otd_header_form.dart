Map<String, String> myFormHeader() {
  Map<String, String> header = {
    'accept': '*/*',
    'User-Agent': 'Mozilla/5.0',
    'Authorization': 'Bearer your formation api key',
    'Content-Type': 'application/xml',
  };

  return header;
}
