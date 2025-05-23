class GetCertificates{
  String evId;
  String eventName;
  String theDate;

  GetCertificates({required this.evId, required this.eventName, required this.theDate});

  GetCertificates.fromJson(Map json)
      : evId = json['evId'],
        eventName = json['eventName'],
        theDate = json['theDate'];
}