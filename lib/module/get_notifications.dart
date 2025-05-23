class GetNotifications{
  String noId;
  String theTitle;
  String theDetails;
  String theType;
  String theDate;
  String eventId;

  GetNotifications({required this.noId, required this.theTitle, required this.theDetails, required this.theType, required this.theDate, required this.eventId});

  GetNotifications.fromJson(Map json)
      : noId = json['noId'],
        theTitle = json['theTitle'],
        theDetails = json['theDetails'],
        theType = json['theType'],
        theDate = json['theDate'],
        eventId = json['eventId'];

}