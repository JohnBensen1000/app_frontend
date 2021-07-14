import 'dart:io';

import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:test_flutter/API/methods/posts.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../globals.dart' as globals;
import '../models/post.dart';

class PostRepository {
  // Responsible for downloading images/videos from google storage. Has three
  // hash maps, imageProviders, thumbnails, and videoPlayers, that are each
  // responsible for storing a different data type. This repository is used to
  // locally store posts so that a seperate call to Google Storage is not needed
  // for every time a post is used. Each post in the hash maps is a key value
  // pair, where the key is a post's postID, and the value is the post itself.
  // Each function has a boolean argument, 'saveInMemory', that determines if a
  // post is actually stored locally.

  HashMap imageProviders = new HashMap<String, ImageProvider>();
  HashMap thumbnails = new HashMap<String, Future<Uint8List>>();
  HashMap videoPlayers = new HashMap<String, VideoPlayerController>();

  ImageProvider getImage(Post post, bool saveInMemory) {
    String postID =
        (post.postID == 'profile') ? post.creator.uid + 'profile' : post.postID;

    ImageProvider imageProvider = (imageProviders.containsKey(postID))
        ? imageProviders[postID]
        : Image.network(post.downloadURL).image;

    if (saveInMemory) imageProviders[postID] = imageProvider;

    return imageProvider;
  }

  Future<Uint8List> getThumbnail(Post post, bool saveInMemory) {
    Future<Uint8List> thumbnail = (thumbnails.containsKey(post.postID))
        ? thumbnails[post.postID]
        : VideoThumbnail.thumbnailData(video: post.downloadURL);

    if (saveInMemory) thumbnails[post.postID] = thumbnail;

    return thumbnail;
  }

  VideoPlayerController getVideoPlayer(Post post, bool saveInMemory) {
    VideoPlayerController videoPlayer = (videoPlayers.containsKey(post.postID))
        ? videoPlayers[post.postID]
        : VideoPlayerController.network(post.downloadURL);

    if (saveInMemory) videoPlayers[post.postID] = videoPlayer;

    return videoPlayer;
  }

  Future<Map> postProfile(bool isImage, File file) async {
    // When a user posts a new profile, the currently cached profile has to be
    // deleted.
    String postID = globals.user.uid + 'profile';

    if (isImage)
      imageProviders.removeWhere((key, value) => key == postID);
    else
      videoPlayers.removeWhere((key, value) => key == postID);

    print(imageProviders.keys);

    return await uploadProfilePic(isImage, file);
  }
}
