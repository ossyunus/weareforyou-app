class GetActivities{
  String neId;
  String theTitle;
  String thePhoto;
  String theDate;

  GetActivities({required this.neId, required this.theTitle, required this.thePhoto, required this.theDate});

  GetActivities.fromJson(Map json)
      : neId = json['neId'],
        theTitle = json['theTitle'],
        thePhoto = json['thePhoto'],
        theDate = json['theDate'];

}