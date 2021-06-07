import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/post.dart';

class PostRepository {
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

    print(imageProviders.keys);
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
}
