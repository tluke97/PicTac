
/*
Parse.Cloud.define("pushsample", function (request, response) {
    Parse.Push.send({
            channels: ["News"],
            data: {
                title: "Hello from the Cloud Code",
                alert: "Back4App rocks!",
            }
       }, {
            success: function () {
                // Push was successful
                response.success("push sent");
                console.log("Success: push sent");
            },
            error: function (error) {
                // Push was unsucessful
                response.error("error with push: " + error);
                console.log("Error: " + error);
            },
            useMasterKey: true
       });
});
*/


/*









Parse.Cloud.define("pushToFollowers", function (request, response) {
console.log("Inside pushToFollowers");
var params = request.params;
var user = request.user;
var sessionToken = user.getSessionToken();
var someKey = request.someKey;
var data = params.data;

var recipientUser = new Parse.Query(Parse.User);
recipientUser.equalTo("objectId", request.params.someKey);

// Set our installation query
var pushQuery = new Parse.Query(Parse.Installation);
pushQuery.equalTo('deviceType', 'ios');
pushQuery.matchesQuery('user', recipientUser);
pushQuery.find({ useMasterKey: true }).then(function(object) {
response.success(object);
console.log("pushQuery got " + object.length);
}, function(error) {
response.error(error);
console.error("pushQuery find failed. error = " + error.message);
});

// Send push notification to query
Parse.Push.send({
where: pushQuery,
data: data
}, { useMasterKey: true })
.then(function() {
// Push sent!
console.log("#### push sent!");
}, function(error) {
// There was a problem :(
console.error("#### push error" + error.message);
});
response.success('success, end of pushToFollowers')
});
























/*


Parse.Cloud.define("pushToFollowers", function (request, response) {
  console.log("Inside pushToFollowers");
  var params = request.params;
  var user = request.user;
  var sessionToken = user.getSessionToken();
  var someKey = request.someKey;
  var data = params.data;

  var recipientUser = new Parse.Query(Parse.posts);
  recipientUser.equalTo('uuid', someKey);
  recipientUser.find({ useMasterKey: true }).then(function(object) {
        response.success(object); 
        console.log("recipientUser found this many: " + object.length);
        }, function(error) {
          response.error(error);
            console.error("recipientUser find failed. error = " + error.message);
    });

// Set our installation query
  var pushQuery = new Parse.Query(Parse.Installation);
   //pushQuery.equalTo('deviceType', 'ios');
   //pushQuery.matchesQuery('user', recipientUser);
   pushQuery.notEqualTo('user', request.user);  
   pushQuery.find({ useMasterKey: true }).then(function(object) {
        response.success(object); 
        console.log("pushQuery found this many: " + object.length);
        }, function(error) {
          response.error(error);
            console.error("pushQuery find failed. error = " + error.message);
    });

  // Send push notification to query
  Parse.Push.send({
    where: pushQuery,
    data: data  
  }, { useMasterKey: true })
    .then(function() {
      // Push sent!
      console.log("#### push sent!");
    }, function(error) {
      // There was a problem :(
      console.error("#### push error" + error.message);
    });
response.success('success, end of pushToFollowers')
});

*/



/*
Parse.Cloud.define('sendPushToYourself', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;
    var params = request.params;
    var likeFrom = params.likeFrom;
    var sendTo = params.sendTo;
    

    var query = new Parse.Query("Installation");
    query.equalTo("userId", userId);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Notification",
            alert: "Like from" + someKey,
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!");
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});



*/

















Parse.Cloud.define('likePush', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;
    var params = request.params;
    var likeFrom = params.likeFrom;
    var sendTo = params.sendTo;
    

    var query = new Parse.Query("Installation");
    query.equalTo("userId", sendTo);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Notification",
            alert: likeFrom + " liked your post.",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!" + sendTo);
            
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});

Parse.Cloud.define('tagPush', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;
    var params = request.params;
    var notificationFrom = params.notificationFrom;
    var sendTo = params.sendTo;
    

    var query = new Parse.Query("Installation");
    query.equalTo("userId", sendTo);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Notification",
            alert: notificationFrom + " tagged you in a post.",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!" + sendTo);
            
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});

Parse.Cloud.define('commentPush', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;
    var params = request.params;
    var notificationFrom = params.notificationFrom;
    var sendTo = params.sendTo;
    

    var query = new Parse.Query("Installation");
    query.equalTo("userId", sendTo);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Notification",
            alert: notificationFrom + " commented on your post.",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!" + sendTo);
            
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});


Parse.Cloud.define('followPush', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;
    var params = request.params;
    var notificationFrom = params.notificationFrom;
    var sendTo = params.sendTo;
    

    var query = new Parse.Query("Installation");
    query.equalTo("userId", sendTo);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Notification",
            alert: notificationFrom + " followed you.",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!" + sendTo);
            
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});



Parse.Cloud.define('requestPush', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;
    var params = request.params;
    var notificationFrom = params.notificationFrom;
    var sendTo = params.sendTo;
    

    var query = new Parse.Query("Installation");
    query.equalTo("userId", sendTo);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Notification",
            alert: notificationFrom + " requested to follow you.",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!" + sendTo);
            
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});

Parse.Cloud.define('screenshotPush', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;
    var params = request.params;
    var notificationFrom = params.notificationFrom;
    var sendTo = params.sendTo;
    

    var query = new Parse.Query("Installation");
    query.equalTo("userId", sendTo);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Notification",
            alert: notificationFrom + " took a screenshot of your post.",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!" + sendTo);
            
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});












