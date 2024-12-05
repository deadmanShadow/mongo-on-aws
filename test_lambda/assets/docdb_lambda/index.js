const { faker } = require('@faker-js/faker');
const { v4: uuidv4 } = require("uuid");

const mongo_url = process.env.MONGO_ENDPOINT;
exports.handler = async (event) => {
  console.log('mongo_url', mongo_url);
  var MongoClient = require('mongodb').MongoClient;
  let response = {};
  try {
    const client = await MongoClient.connect(mongo_url, { useNewUrlParser: true, useUnifiedTopology: true });
    const db = client.db(); // Get the database object
    console.log("Database created!");
    console.log("Switched to " + db.databaseName + " database");
    // create collection if not exists
    const collections = await db.listCollections().toArray();
    const collectionNames = collections.map((collection) => collection.name);
    console.log(collectionNames);
    if (!collectionNames.includes("users")) {
      console.log("Collection not found, creating collection");
      const result = await db.createCollection("users");
      console.log("Collection is created!");
    }
    const usrName = uuidv4();
    var userobj = { username: usrName, fname: "Test", lname: "User", address: "Test address" };
    const result = await db.collection("users").insertOne(userobj);
    console.log("1 document inserted");
    const qryresult = await db.collection("users").find({}).toArray();
    console.log("Query result");
    console.log(qryresult);
    client.close();
    response = {
      statusCode: 200,
      body: JSON.stringify("Collection created and queried successfully"),
    };
  }
  catch (errval) {
    console.log(errval);
    response = {
      statusCode: 500,
      body: JSON.stringify("error"),
    };

  }
  response = {
    statusCode: 200,
    body: JSON.stringify("success"),
  };
  return response;
};

