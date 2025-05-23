class GetFaq{
  String faId;
  String theTitle;
  String theDetails;

  GetFaq({required this.faId, required this.theTitle, required this.theDetails});

  GetFaq.fromJson(Map json)
      : faId = json['faId'],
        theTitle = json['theTitle'],
        theDetails = json['theDetails'];

}