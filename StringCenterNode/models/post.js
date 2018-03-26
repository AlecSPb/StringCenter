const mongoose = require('mongoose');
const Tab = require('./tabModel');
const User = require('./user');
const Group = require('./group');
const util = require('../middleware/util');

let PostSchema = mongoose.Schema({
    content: {
        type: String,
        maxlength: [500, 'Content cannot be longer than 500 characters'],
        required: true,
        trim: true
    },
    // as of now, posts can only contain one tab
    tabId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Tab'
    },
    groupName: {
        type: String,
        ref: 'Group'
    },
    authorUsername: {
        type: String,
        required: true,
        ref: 'User'
    },
    dateCreated: {
        type: Date,
        required: true,
        default: Date.now
    }
});

// Verify that the user trying to delete actually created the post
PostSchema.statics.validateUserAndRemove = function(id, username, callback) {
    PostSchema.findById(id, function (error, post) {
        if (error) {
            return callback(error);
        } else if (!post) {
            return callback(null, false);
        } else if (post.authorUsername !== username) {
            let err = new Error('Unauthorized');
            return callback(err);
        }
        post.remove(function (er, removed) {
            if (er) {
                return callback(er);
            }
            return callback(null, removed);
        });
    });
};

PostSchema.statics.search = function(regex, callback) {
    Post.find({
        $or: [
            { content: regex }
        ]
    }, {}, { limit: 100 }, function(error, posts) {
        if (error) {
            return callback(error);
        }
        return callback(null, posts);
    });
};

PostSchema.methods.validateAndSave = function(callback) {
    util.validateAndSave(this, callback);
};

let Post = mongoose.model('Post', PostSchema);
module.exports = Post;
