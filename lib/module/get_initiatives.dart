class GetInitiatives{
  String inId;
  String theTitle;
  String theDetails;
  String thePhoto;

  GetInitiatives({required this.inId, required this.theTitle, required this.theDetails, required this.thePhoto});

  GetInitiatives.fromJson(Map json)
      : inId = json['inId'],
        theTitle = json['theTitle'],
        theDetails = json['theDetails'],
        thePhoto = json['thePhoto'];

}