const Express = require("express");
const BodyParser = require("body-parser");
const MongoClient = require("mongodb").MongoClient;
const ObjectId = require("mongodb").ObjectID;
const CONNECTION_URL = "mongodb+srv://Developer_1:Developer_1@woolalacluster.o4vv6.mongodb.net/Feed?retryWrites=true&w=majority";
//const CONNECTION_URL = "mongodb+srv://Lead_Devloper:poQLxqdUb4c2RfvJ@woolalacluster.o4vv6.mongodb.net/Feed?retryWrites=true&w=majority";
// const CONNECTION_URL = "mongodb://127.0.0.1:27017";
const DATABASE_NAME = "Feed";

const path = require("path")


var app = Express();
app.use(Express.json({limit: '50mb'}));
app.use(Express.urlencoded({limit: '50mb'}));
app.use(BodyParser.json());
app.use(BodyParser.urlencoded({ extended: true }));

var database, collection;

app.listen(process.env.PORT || 5000, () => {
    MongoClient.connect(CONNECTION_URL, { useNewUrlParser: true, useUnifiedTopology: true }, (error, client) => {
        if(error) {
            throw error;
        }
        database = client.db("Feed");
        collection = database.collection("Posts");
        userCollection = database.collection("Users");
        reportCollection = database.collection("ReportedPosts");
        conversationCollection = database.collection("Conversations");
        messageCollection = database.collection("Messages");
        console.log("Connected to `" + DATABASE_NAME + "`!");
    });
});

app.use(Express.static(path.join(__dirname+'/assets/')));
app.get('/eula', (request, response) => {
  response.sendFile(path.join(__dirname+'/assets/EULA.html'));
});

app.post("/insertPost", (request, response) => {
    collection.insertOne(request.body, (error, result) => {
        if(error) {
            return response.status(500).send(error);
        }
        response.send(result.result);
    });
    var userID = request.body.userID;
    var postID = request.body.postID;
    var newVal = { $push: { postIDs: postID }};
    userCollection.updateOne({"userID":userID}, newVal, function(err, res) {
      console.log("Post Added");
    });
});

//create a user
app.post("/insertUser", (request, response) => {
    userCollection.insertOne(request.body, (error, result) => {
        if(error) {
            return response.status(500).send(error);
        }
        response.send(result.result);
    });
});

// handles everything that needs to happen when a post is rated
app.post("/ratePost/:id/:rating/:userID", (request, response) => {
  collection.findOne({"postID":request.params.id}, function(err, document) {
  var newNumRatings = 1 + document.numRatings;
  var newCumulativeRating = parseInt(request.params.rating) + document.cumulativeRating;
  console.log(newNumRatings);
  console.log(newCumulativeRating);
  var newvalues = { $set: {numRatings: newNumRatings, cumulativeRating: newCumulativeRating } };
  collection.updateOne({"postID":request.params.id}, newvalues, function(err, res) {
  console.log("1 document updated");
    });
  });

  var updateRated = { $push: { ratedPosts: [request.params.id, request.params.rating] }};
  userCollection.updateOne({"userID":request.params.userID}, updateRated, function(err, res) {
    console.log("ratedPosts updated");
  });
  response.send({"it":"worked"});
});


app.post("/updateUserBio/:id/:bio", (request, response) => {
  var newBio = { $set: {"bio": request.params.bio} };
  userCollection.updateOne({"userID":request.params.id}, newBio, function(err, res){
    if (err) throw err;
    console.log("USER: " + request.params.id + "\nNew Bio: " + request.params.bio);
    response.send(res);
  });
});

app.post("/updateUserName/:id/:name", (request, response) => {
  var newName = { $set: {"userName": request.params.name} };
  userCollection.updateOne({"userID":request.params.id}, newName, function(err, res){
    if (err) throw err;
    console.log("USER: " + request.params.id + "\nNew Name: " + request.params.name);
    response.send(res);
  });
});

app.post("/updateUserProfileName/:id/:name", (request, response) => {
  var newName = { $set: {"profileName": request.params.name} };
  userCollection.updateOne({"userID":request.params.id}, newName, function(err, res){
    if (err) throw err;
    console.log("New Name: " + request.params.name);
    response.send(res);
  });
});

app.post("/updateUserPrivacy/:id/:private", (request, response) => {
  var privacyBool = request.params.private == 'true';
  var newPrivacy = { $set: {"private": privacyBool}};
  userCollection.updateOne({"userID":request.params.id}, newPrivacy, function(err, res){
    if (err) throw err;
    console.log("Account Privacy: " + privacyBool);
    response.send(res);
  });
});

app.post("/updateUserProfilePic/:id", (request, response) => {
  //console.log(request.params.image64str);
  var newPic = { $set: request.body};
 //console.log(newPic);
  userCollection.updateOne({"userID":request.params.id}, newPic, function(err, res){
    if (err) throw err;
    console.log("Profie Picture changed!");
    response.send(res);
  });
});

app.post("/updateURL/:id/:url", (request, response) => {
  var newUrl = { $set: { "url": request.params.url } };
  userCollection.updateOne({ "userID": request.params.id }, newUrl, function (err, res) {
    if (err) throw err;
    console.log("New URL: " + request.params.url);
    response.send(res);
  });
})

//returns the entire post
app.get("/getPostInfo/:id", (request, response) => {
    collection.findOne({"postID":request.params.id}, function(err, document) {
    response.send(document);
    });
});

app.get("/doesUserExist/:email", (request, response) => {
  console.log("Requesting user with email: " + request.params.email);
    userCollection.findOne({"email":request.params.email}, function(err, document) {
      if(document)
      {
        //console.log(document);
        console.log("Found user: " + document.userID);
        response.send(document);
        }
      else
      {
      response.send(err);
      }
    });
});

// gets a user by userID
app.get("/getUser/:userID", (request, response) => {
  console.log("Requesting user " + request.params.userID);
    userCollection.findOne({"userID":request.params.userID}, function(err, document) {
      if(document)
        console.log("Found user: " + request.params.userID);
        response.send(document);
    });
});

app.get("/getUserByUserName/:userName", (request, response) => {
  console.log("Checking if " + request.params.userName + " exists");
    userCollection.findOne({"userName":request.params.userName}, function(err, document) {
      if(document)
        console.log("Found user! with UserName: " + request.params.userName);
        response.send(document);
    });
});

app.get("/getAllUsers", (request, response) => {
    userCollection.find({}).toArray(function(err, documents) {
        if(documents)
            //console.log("Retrieved all Users");
            response.send(documents);
            //console.log(documents);
    });
});


// gets a list of postID's from all the users that the provided user is following
app.get("/getFeed/:userID", (request, response) => {
      console.log('Feed requested for user ' + request.params.userID);

      var postIDs = [];
      userCollection.findOne({"userID":request.params.userID}, function(err, document) {
        if(document)
        {
          var following = document.following;
          userCollection.find({"userID": {$in: following}}).toArray(function(err, results)
          {
              for(var i = 0; i < results.length; i++)
              {
                postIDs.push(...results[i].postIDs);
              }
              // console.log(postIDs);
              response.send({"postIDs":postIDs});
          });
        }
      });
});

app.get("/getOwnFeed/:userID", (request, response) => {
      console.log('Feed requested for user ' + request.params.userID);
      var postIDs = [];
      userCollection.findOne({"userID":request.params.userID}, function(err, document) {
      response.send(document.postIDs);
      });
});


// handles following a user
app.post("/follow/:you/:them", (request, response) => {
    var currentUserID = request.params.you;
    var followUserID = request.params.them;
    var updateCurrent = { $push: { following: followUserID }};
    var updateOther = { $push: { followers: currentUserID }};

    userCollection.updateOne({"userID":currentUserID}, updateCurrent, function(err, res) {
      console.log(currentUserID + " now has " + followUserID + " in their following array");
    });

    userCollection.updateOne({"userID":followUserID}, updateOther, function(err, res) {
      console.log(followUserID + " now has " + currentUserID + " in their followers array");
    });
    response.send({});
});

// handles unfollowing a user
app.post("/unfollow/:you/:them", (request, response) => {
    var currentUserID = request.params.you;
    var unfollowUserID = request.params.them;
    var updateCurrent = { $pull: {following: unfollowUserID}};
    var updateOther = { $pull: {followers: currentUserID}};

    userCollection.updateOne({"userID":currentUserID}, updateCurrent, function(err, res) {
      console.log(currentUserID + " now does not have " + unfollowUserID + " in their following array");
    });

    userCollection.updateOne({"userID":unfollowUserID}, updateOther, function(err, res) {
      console.log(unfollowUserID + " now does not have " + currentUserID + " in their followers array");
    });
    response.send({});
});

// handles blocking a user
app.post("/blockUser/:you/:them", (request, response) => {
  var currentUserID = request.params.you;
  var blockedUserID = request.params.them;
  var updateCurrent = { $push: { blockedUsers: blockedUserID } };

  userCollection.updateOne({ "userID": currentUserID }, updateCurrent, function (err, res) {
    console.log(currentUserID + " now has " + blockedUserID + " in their blocked Users array");
  });
  response.send({});
});

// handles blocking a user
app.post("/unblockUser/:you/:them", (request, response) => {
  var currentUserID = request.params.you;
  var blockedUserID = request.params.them;
  var updateCurrent = { $pull: { blockedUsers: blockedUserID } };

  userCollection.updateOne({ "userID": currentUserID }, updateCurrent, function (err, res) {
    console.log(currentUserID + " now does not have " + blockedUserID + " in their blocked Users array");
  });
  response.send({});
});

app.post("/deleteUser/:ID", (request, response) => {
    userCollection.deleteOne({"userID": request.params.ID}, function(err, res) {
        console.log("Deleted User: " + request.params.ID);
        if(err) console.log(err);
    });
});

app.post("/deleteAllPosts/:ID", (request, response) => {
    collection.deleteMany({"userID": request.params.ID}, function(err, res) {
        console.log("Deleting all Posts by user: " + request.params.ID);
    });
});

// deleted the post with the provided postID
app.post("/deleteOnePost/:postID/:userID", (request, response) => {
  var update = { $pull: {"postIDs": request.params.postID} };
  userCollection.updateOne({"userID":request.params.userID}, update, function(err, res){});

    collection.deleteOne({"postID": request.params.postID}, function(err, res) {
        console.log("Deleted Post: " + request.params.postID);
        if(err) console.log(err);
        response.send(res);
    });
});


app.get("/getRatedPosts/:userID", (request, response) => {
  console.log('Rated posts requested for user ' + request.params.userID);
    userCollection.findOne({"userID":request.params.userID}, function(err, document) {
      // console.log(document);
      response.send(document.ratedPosts);
    });
});

app.post("/reportPost", (request, response) => {
    reportCollection.insertOne(request.body, (error, result) => {
        if(error) {
            return response.status(500).send(error);
        }
        response.send(result.result);
        console.log(request.body);
    });
});

//currently gets post ID and sends back how many reports from different users a post has
//scalability steps: modify to send back reports/userIDs (for review), remember user reported for future deactivation
app.get("/getReports/:postID", (request,response) => {
    console.log("Getting reports for PostID: " + + request.params.postID + "...");
    var userIDs = [];
    reportCollection.find({"postID":request.params.postID}).toArray(function(err, reports) {
        if (reports) {
            for (var i = 0; i < reports.length; ++i) {
                var existingUser = false;
                for (var j = 0; j < userIDs.length; ++j) {
                    if (reports[i].reportingUserID === userIDs[j]) {
                        existingUser = true;
                    }
                }
                if (existingUser === false) {
                    userIDs.push(reports[i].reportingUserID);
                }
            }
            console.log("Reporting users: ");
            console.log(userIDs);
            response.send({"numReports": userIDs.length});
        }
    });
});

app.post("/wouldBuy/:postID/:userID", (request, response) => {
    var userID = request.params.userID;
    var postID = request.params.postID;
    var updateCurrent = { $push: { wouldBuy: userID }};

    collection.updateOne({"postID":postID}, updateCurrent, function(err, res) {
      console.log(postID + " now has " + userID + " in their wouldBuy array");
      response.send(res);
    });

    //response.send({});
});


app.post("/removeWouldBuy/:postID/:userID", (request, response) => {
    var userID = request.params.userID;
    var postID = request.params.postID;
    var updateCurrent = { $pull: { wouldBuy: userID }};

    collection.updateOne({"postID":postID}, updateCurrent, function(err, res) {
      console.log(postID + " now has " + userID + " in their wouldBuy array");
      response.send(res);
    });

    //response.send({});
});

app.get("/checkWouldBuy/:postID", (request, response) => {
    var postID = request.params.postID;
    collection.findOne({"postID":postID}, function(err, document) {
    response.send(document.wouldBuy);
    });
});

// Jialin Li - CSCE 606 Spring 2022
// Methods related to DM and ClientList

// making a user client
app.post("/makeClient/:you/:them", (request, response) => {
  var currentUserID = request.params.you;
  var targetUserID = request.params.them;
  var updateCurrent = { $push: { clients: targetUserID } };

  userCollection.updateOne({ "userID": currentUserID }, updateCurrent, function (err, res) {
    console.log(currentUserID + " now has " + targetUserID + " in their client array");
  });
  response.send({});
});

// removing a user as client
app.post("/removeClient/:you/:them", (request, response) => {
  var currentUserID = request.params.you;
  var targetUserID = request.params.them;
  var updateCurrent = { $pull: { clients: targetUserID } };

  userCollection.updateOne({ "userID": currentUserID }, updateCurrent, function (err, res) {
    console.log(currentUserID + " now does not have " + targetUserID + " in their clients array");
  });
  response.send({});
});

// get conversation between two users if exist
app.get("/doesConversationExist/:user1/:user2", (request, response) => {
    var str1 = "";
    var str2 = "";
    if (request.params.user1 <= request.params.user2) {
        str1 = request.params.user1;
        str2 = request.params.user2;
    } else {
        str1 = request.params.user2;
        str2 = request.params.user1;
    }
    var uniqID = str1+":::"+str2;
    console.log("Finding conversation between "+str1+" and "+str2);

    conversationCollection.findOne({"UniqueID":uniqID}, function(err, document) {
        if(document) {
            console.log("Found conversation between: " + str1+" and "+str2);
            response.send(document);
        } else {
            response.send(err);
        }
    });
});

app.get("/getConversationByID/:uniqID", (request, response) => {
  console.log('Conversation file requested for unique id ' + request.params.uniqID);
    conversationCollection.findOne({"UniqueID":request.params.userID}, function(err, document) {
      // console.log(document);
      // returns a Conversation instance
      response.send(document);
    });
});

app.get("/getConversationList/:userID", (request, response) => {
  console.log('Conversation list requested for user ' + request.params.userID);
    userCollection.findOne({"userID":request.params.userID}, function(err, document) {
      // console.log(document);
      response.send(document.conversations);
    });
});

// create a conversation file between 2 users if not already exist
// this method and the previous one are called in models/conversation.dart
app.post("/insertConversation", (request, response) => {
    conversationCollection.insertOne(request.body, (error, result) => {
        if(error) {
            return response.status(500).send(error);
        }
        response.send(result.result);
    });
    var user1 = request.body.User1;
    var user2 = request.body.User2;
    var newVal = { $push: { conversations: request.body.UniqueID }};
    userCollection.updateOne({"userID":user1}, newVal, function(err, res) {
      console.log("Conversation file stored to "+user1);
    });
    userCollection.updateOne({"userID":user2}, newVal, function(err, res) {
      console.log("Conversation file stored to "+user2);
    });

});




