import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/user_model.dart';
import '../../services/auth_service/auth_service.dart';

class AuthenticationProvider extends ChangeNotifier{
  XFile? pickedImage;
  final _authService = AuthService.instance;

  bool _isSigningUp = false;
  bool _isCompletingProfile = false;

  bool get isSigningUp => _isSigningUp;
  bool get isCompletingProfile => _isCompletingProfile;

  void onPickImageTap()async{
    ImagePicker imagPicked = ImagePicker();
    pickedImage = await imagPicked.pickImage(source: .gallery);
    if(pickedImage != null){
      notifyListeners();
    }
  }



  Future<String?> onCreateAccountTap({required String email, required String name, required String password})async{
    _isSigningUp = true;
    notifyListeners();
    try{
      await _authService.signup(name: name, email: email, password: password);
      return null;
    }catch(e){
      return e.toString();
    }finally{
      _isSigningUp = false;
      notifyListeners();
    }
  }

  Future<String?> onCompleteProfileTap({
    required String phoneNum,
    required String vehicleName,
    required String vehicleColor,
    required String licensePlateNum,
    required String registrationNum,
    required String emergencyContact}) async {
    _isCompletingProfile = true;
    notifyListeners();
    try{
      UserModel? user = await _authService.getCurrentUser();
      if(user != null){
        VehicleInformation vehicleInformation = VehicleInformation(name: vehicleName, color: vehicleColor, registrationNumber: registrationNum, licensePlateNumber: licensePlateNum);
        final updatedUser = user.copyWith(vehicleInformation: vehicleInformation, emergencyContacts: [emergencyContact]);
        return await _authService.updateUser(user: updatedUser);
      }
      return null;
    }catch(e){
      return e.toString();
    }finally{
      _isCompletingProfile = false;
      notifyListeners();
    }
  }
}