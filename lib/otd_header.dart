// hier muss der Schluessel von opentransportdata.swiss eingetragen werden
Map<String, String> myHeader() {
  Map<String, String> header = {
    'accept': '*/*',
    'Authorization':
        'Bearer your_key_for_opentransportdata',
    'Content-Type': 'application/xml'
  };

  return header;
}
