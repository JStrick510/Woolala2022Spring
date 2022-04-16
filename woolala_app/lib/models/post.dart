class Post {
  final String ID;
  final String UserID;
  final String ImageID1;
  final String ImageID2;
  final String ImageID3;
  final String ImageID4;
  final String ImageID5;
  final String Date;
  final String Description;
  final String Comments;
  final double CumulativeRating;
  final int NumRatings;
  final String Category;
  //final String price;

  Post({
    this.ID, this.UserID, this.ImageID1, this.ImageID2, this.ImageID3, this.ImageID4, this.ImageID5, this.Date, this.Description, this.Comments, this.CumulativeRating, this.NumRatings, this.Category,
  });

  Post.fromJSON(Map<String, dynamic> json)
    : ID = json["ID"],
      UserID = json["UserID"],
      ImageID1 = json["ImageID1"],
      ImageID2 = json["ImageID2"],
      ImageID3 = json["ImageID3"],
      ImageID4 = json["ImageID4"],
      ImageID5 = json["ImageID5"],
      Date = json["Date"],
      Description = json["Description"],
      Comments = json["Comments"],
      CumulativeRating = json["CumulativeRating"],
      NumRatings = json["NumRatings"],
      Category = json["Category"];
      // price = json["price"]

  Map<String, dynamic> toJSON() => {
    "ID" : ID,
    "UserID" : UserID,
    "ImageID1" : ImageID1,
    "ImageID2" : ImageID2,
    "ImageID3" : ImageID3,
    "ImageID4" : ImageID4,
    "ImageID5" : ImageID5,
    "Date" : Date,
    "Description" : Description,
    "Comments" : Comments,
    "CumulativeRating" : CumulativeRating,
    "NumRatings" : NumRatings,
    "Category" : Category,
    // "price" : price,
  };
}
