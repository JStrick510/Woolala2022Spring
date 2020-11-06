const Express = require("express");
const BodyParser = require("body-parser");
const MongoClient = require("mongodb").MongoClient;
const ObjectId = require("mongodb").ObjectID;
const CONNECTION_URL = "mongodb+srv://Developer_1:Developer_1@woolalacluster.o4vv6.mongodb.net/Feed?retryWrites=true&w=majority";
//const CONNECTION_URL = "mongodb+srv://Lead_Devloper:poQLxqdUb4c2RfvJ@woolalacluster.o4vv6.mongodb.net/Feed?retryWrites=true&w=majority";
const DATABASE_NAME = "Feed";


var app = Express();
app.use(Express.json({limit: '50mb'}));
app.use(Express.urlencoded({limit: '50mb'}));
app.use(BodyParser.json());
app.use(BodyParser.urlencoded({ extended: true }));

var database, collection;

app.listen(5000, () => {
    MongoClient.connect(CONNECTION_URL, { useNewUrlParser: true, useUnifiedTopology: true }, (error, client) => {
        if(error) {
            throw error;
        }
        database = client.db("Feed");
        collection = database.collection("Posts");
        userCollection = database.collection("Users");
        console.log("Connected to `" + DATABASE_NAME + "`!");
    });
});


app.post("/insertPost", (request, response) => {
    collection.insertOne(request.body, (error, result) => {
        if(error) {
            return response.status(500).send(error);
        }
        response.send(result.result);
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

app.post("/ratePost/:id/:rating", (request, response) => {
  collection.findOne({"postID":parseInt(request.params.id)}, function(err, document) {
  var newNumRatings = 1 + document.numRatings;
  var newCumulativeRating = parseInt(request.params.rating) + document.cumulativeRating;
  console.log(newNumRatings);
  console.log(newCumulativeRating);
  var newvalues = { $set: {numRatings: newNumRatings, cumulativeRating: newCumulativeRating } };
  collection.updateOne({"postID":parseInt(request.params.id)}, newvalues, function(err, res) {

  console.log("1 document updated");
    });
  });
});


app.get("/getPostInfo/:id", (request, response) => {
    collection.findOne({"postID":parseInt(request.params.id)}, function(err, document) {
    response.send(document);
    });
});

app.get("/doesUserExist/:email", (request, response) => {
    userCollection.findOne({"email":request.params.email}, function(err, document) {
      if(document)
        console.log(document);
        response.send(document);

    });
});


app.get("/getFeed/:userID/:date", (request, response) => {
      console.log('Feed requested for user ' + request.params.userID + " date: " + request.params.date);

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
              console.log(postIDs);
              response.send({"postIDs":postIDs});
          });
        }
      });

});
