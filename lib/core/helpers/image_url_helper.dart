import '../res/app_constants.dart';

class ImageUrlHelper {
  static String getImageUrl(String path){
    return path.replaceAll('public', AppConstants.imageBaseUrl);
  }
}