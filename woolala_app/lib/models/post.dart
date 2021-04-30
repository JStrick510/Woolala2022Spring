class Post {
  final String ID;
  final String UserID;
  final String Image;
  final String Date;
  final String Description;
  final String Comments;
  final double CumulativeRating;
  final int NumRatings;
  final String status;
  final List<String> ratedBy;
  final String userName;

  Post({
    this.ID,
    this.UserID,
    this.Image,
    this.userName,
    this.Date,
    this.Description,
    this.Comments,
    this.CumulativeRating,
    this.NumRatings,
    this.status,
    this.ratedBy,
  });

  Post.fromJSON(Map<String, dynamic> json)
      : ID = json["ID"],
        UserID = json["UserID"],
        Image = json["Image"],
        Date = json["Date"],
        Description = json["Description"],
        Comments = json["Comments"],
        CumulativeRating = json["CumulativeRating"],
        NumRatings = json["NumRatings"],
        status = json["status"],
        ratedBy = json["ratedBy"],
        userName = json["userName"];

  Map<String, dynamic> toJSON() => {
        "ID": ID,
        "UserID": UserID,
        "Image": Image,
        "Date": Date,
        "Description": Description,
        "Comments": Comments,
        "CumulativeRating": CumulativeRating,
        "NumRatings": NumRatings,
        "status": status,
        "ratedBy": ratedBy,
        "userName": userName,
      };
}
