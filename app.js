const Express = require("express");
const BodyParser = require("body-parser");
const MongoClient = require("mongodb").MongoClient;
const ObjectId = require("mongodb").ObjectID;
const CONNECTION_URL = "mongodb+srv://Developer_1:7G0RD5tCpJkVLsnH@woolalacluster.o4vv6.mongodb.net/Feed?retryWrites=true&w=majority";
//const CONNECTION_URL = "mongodb+srv://Lead_Devloper:poQLxqdUb4c2RfvJ@woolalacluster.o4vv6.mongodb.net/Feed?retryWrites=true&w=majority";
const DATABASE_NAME = "Feed";


var app = Express();
app.use(BodyParser.json());
app.use(BodyParser.urlencoded({ extended: true }));
var database, collection;

app.listen(5000, () => {
    MongoClient.connect(CONNECTION_URL, { useNewUrlParser: true }, (error, client) => {
        if(error) {
            throw error;
        }
        database = client.db("Feed");
        collection = database.collection("Posts");
        console.log("Connected to `" + DATABASE_NAME + "`!");
    });
});


app.post("/test", (request, response) => {
    collection.insert(request.body, (error, result) => {
        if(error) {
            return response.status(500).send(error);
        }
        response.send(result.result);
    });
});
