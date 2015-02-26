Parse.Cloud.beforeSave("Nomination", function(request, response) {
	query = new Parse.Query("Nomination");
	query.equalTo("from", request.object.get("from"));
	query.equalTo("to", request.object.get("to"));
	query.equalTo("challenge", request.object.get("challenge"));

	query.find({
		success: function(nominations) {
			if (nominations.length>0) {
				response.error("Nomination already exists");
			} else {
				response.success();
			}
		},
		error: function(error) {
			console.error("Got an error saving nominations " + error.code + " : " + error.message);
			response.error("Nomination error appeared");
		}
	});
});

Parse.Cloud.afterSave("ChallengeSolution", function(request) {
	if (request.object.get("user")) {
		query = new Parse.Query("Nomination");
		query.equalTo("to", request.object.get("user"));
		query.equalTo("challenge", request.object.get("challenge"));
		// console.log("will try to remove nominations for " + request.object.get("user").id + " in challenge " + request.object.get("challenge").id);
		query.find({
			success: function(nominations) {
				// console.log("found nominations " + nominations);
			  	Parse.Object.destroyAll(nominations, {
			        success: function() {},
			        error: function(error) {
			          console.error("Error deleting nominations" + error.code + ": " + error.message);
	        		}
      			});
			},
			error: function(error) {
				console.error("Got an error " + error.code + " : " + error.message);
			}
		});
	}
});

Parse.Cloud.afterSave("Comment", function(request) {
	if (request.object.get("challenge")) {
		query = new Parse.Query("Challenge");
		query.get(request.object.get("challenge").id, {
			success: function(post) {
			  post.increment("comments");
			  post.save();
			},
			error: function(error) {
			  console.error("Got an error " + error.code + " : " + error.message);
			}
		});
	} else {
		query = new Parse.Query("ChallengeSolution");
		query.get(request.object.get("challengeSolution").id, {
			success: function(post) {
			  post.increment("comments");
			  post.save();
			},
			error: function(error) {
			  console.error("Got an error " + error.code + " : " + error.message);
			}
		});
	}	
});

Parse.Cloud.afterSave("Like", function(request) {
	if (request.object.get("challenge")) {
		query = new Parse.Query("Challenge");
	  	query.get(request.object.get("challenge").id, {
		    success: function(post) {
		      post.increment("likes");
		      post.save();
		    },
		    error: function(error) {
		      console.error("Got an error " + error.code + " : " + error.message);
		    }
	  	});
	} else {
		query = new Parse.Query("ChallengeSolution");
	  	query.get(request.object.get("challengeSolution").id, {
		    success: function(post) {
		      post.increment("likes");
		      post.save();
		    },
		    error: function(error) {
		      console.error("Got an error " + error.code + " : " + error.message);
		    }
	  	});
	}
});

Parse.Cloud.afterDelete("Comment", function(request) {
	if (request.object.get("challenge")) {
		query = new Parse.Query("Challenge");
		query.get(request.object.get("challenge").id, {
			success: function(post) {
			  post.increment("comments",-1);
			  post.save();
			},
			error: function(error) {
			  console.error("Got an error " + error.code + " : " + error.message);
			}
		});
	} else {
		query = new Parse.Query("ChallengeSolution");
		query.get(request.object.get("challengeSolution").id, {
			success: function(post) {
			  post.increment("comments",-1);
			  post.save();
			},
			error: function(error) {
			  console.error("Got an error " + error.code + " : " + error.message);
			}
		});
	}
});

Parse.Cloud.beforeSave("Like", function(request, response) {
	query = new Parse.Query("Like");
	query.equalTo("author", request.object.get("author"));
	if (request.object.get("challenge")) {
		query.equalTo("challenge", request.object.get("challenge"));
	} else {
		query.equalTo("challengeSolution", request.object.get("challengeSolution"));	
	}
	
	query.find({
		success: function(likes) {
			if (likes.length>0) {
				response.error("Like already exists");
			} else {
				response.success();
			}
		},
		error: function(error) {
			response.error("Some error appeared");
		}
	});
});

Parse.Cloud.afterDelete("Like", function(request) {
  if (request.object.get("challenge")) {
		query = new Parse.Query("Challenge");
	  	query.get(request.object.get("challenge").id, {
		    success: function(post) {
		      post.increment("likes",-1);
		      post.save();
		    },
		    error: function(error) {
		      console.error("Got an error " + error.code + " : " + error.message);
		    }
	  	});
	} else {
		query = new Parse.Query("ChallengeSolution");
	  	query.get(request.object.get("challengeSolution").id, {
		    success: function(post) {
		      post.increment("likes",-1);
		      post.save();
		    },
		    error: function(error) {
		      console.error("Got an error " + error.code + " : " + error.message);
		    }
	  	});
	}
});