import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/user_model.dart';
import '../services/profile_service/profile_service.dart';

class ProfileProvider extends ChangeNotifier{
  final _profileService = ProfileService.instance;
  bool _loadingProfile = false;
  bool _updatingProfile = false;

  UserModel? _user;
  XFile? _pickedImage;
  bool get loadingProfile => _loadingProfile;
  bool get updatingProfile => _updatingProfile;
  UserModel? get user => _user;
  XFile? get pickedImage => _pickedImage;

  ProfileProvider(){
    _initProfile();
  }

  _initProfile()async{
    _loadingProfile = true;
    notifyListeners();
    try{
    _user = await _profileService.getCurrentUser();
    }catch(e){
      debugPrint("Error while fetching user: ${e.toString()}");
    }
    _loadingProfile = false;
    notifyListeners();
  }


  void onPickImageTap()async{
    ImagePicker imagePicker = ImagePicker();
    XFile? selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if(selectedImage != null){
      _pickedImage = selectedImage;
      notifyListeners();
    }
  }


  Future<String?> onUpdateTap({required String name, required String phoneNum, required String vehicleName, required String color, required String licensePlateNum, required String registrationNum}) async {

    String? errorMessage;
    if(user != null){
      _updatingProfile = true;
      notifyListeners();
      try{
        //Profile image will be added later
        final updatedUser = user!.copyWith(
          userName: name,
          phoneNum: phoneNum.isNotEmpty ? phoneNum : null,
          vehicleInformation: user!.vehicleInformation!.copyWith(name: vehicleName, color: color, licensePlateNumber: licensePlateNum, registrationNumber: registrationNum),
        );
        _user = updatedUser;
        notifyListeners();
        await  _profileService.updateUser(user: updatedUser);
      }catch(e){
        errorMessage= e.toString();
      }
    }else{
      errorMessage = 'User not found';
    }

    _updatingProfile = false;
    notifyListeners();
    return errorMessage;
  }
}