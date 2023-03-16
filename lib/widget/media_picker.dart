import 'package:images_picker/images_picker.dart';

class MediaPicker {
  /// Pick image from gallery
  /// [maxPickFileCount] provide image count
  /// [allowCrop] crop image after pick
  /// [aspectRatio] aspect ratio of picked image
  static Future<List<Media>?> pickImageFromGallery({
    int maxPickFileCount = 1,
    CropOption? cropOption,
  }) async {
    return await ImagesPicker.pick(
      count: maxPickFileCount,
      pickType: PickType.image,
      quality: 0.5,
      maxSize: 800,
      cropOpt: cropOption,
    );
  }

  /// Pick image from camera
  /// [allowCrop] crop image after pick
  /// [aspectRatio] aspect ratio of picked image
  static Future<List<Media>?> pickImageFromCamera({
    CropOption? cropOption,
  }) async {
    return await ImagesPicker.openCamera(
      pickType: PickType.image,
      quality: 0.5,
      maxSize: 800,
      cropOpt: cropOption,
    );
  }

  /// Pick video from gallery
  /// [maxPickFileCount] provide image count
  /// [aspectRatio] aspect ratio of picked image
  static Future<List<Media>?> pickVideoFromGallery({
    int maxPickFileCount = 1,
    CropAspectRatio aspectRatio = CropAspectRatio.wh16x9,
  }) async {
    return await ImagesPicker.pick(
      count: maxPickFileCount,
      pickType: PickType.video,
      quality: 0.5,
      maxSize: 800,
    );
  }

  /// Pick video from camera
  /// [aspectRatio] aspect ratio of picked image
  static Future<List<Media>?> pickVideoFromCamera({
    CropAspectRatio aspectRatio = CropAspectRatio.wh16x9,
  }) async {
    return await ImagesPicker.openCamera(
      pickType: PickType.video,
      quality: 0.5,
      maxSize: 800,
    );
  }
}
