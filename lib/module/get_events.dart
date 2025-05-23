class GetEvents{
  String evId;
  String theTitle;
  String theDetails;
  String thePhoto;
  String theDate;
  String theTime;
  String location;

  GetEvents({required this.evId, required this.theTitle, required this.theDetails, required this.thePhoto, required this.theDate, required this.theTime, required this.location});

  GetEvents.fromJson(Map json)
      : evId = json['evId'],
        theTitle = json['theTitle'],
        theDetails = json['theDetails'],
        thePhoto = json['thePhoto'],
        theDate = json['theDate'],
        theTime = json['theTime'],
        location = json['location'];

}