class GetBranches{
  late String coId;
  late String theBranchName;
  late String theAddress;
  late String phoneNumber;
  late String website;
  late String emailAddress;

  GetBranches({required this.coId, required this.theBranchName, required this.theAddress, required this.phoneNumber, required this.website, required this.emailAddress});

  GetBranches.fromJson(Map json)
      : coId = json['coId'],
        theBranchName = json['theBranchName'],
        theAddress = json['theAddress'],
        phoneNumber = json['phoneNumber'],
        website = json['website'],
        emailAddress = json['emailAddress'];

}