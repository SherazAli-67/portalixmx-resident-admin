import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import '../../services/auth_service/auth_service.dart';

class AuthenticationProvider extends ChangeNotifier{
  XFile? pickedImage;
  final _authService = AuthService.instance;

  bool _isSigningUp = false;
  bool isSigningIn = false;
  bool loadingSocieties = false;
  String? societiesError;

  bool get isSigningUp => _isSigningUp;
  List<SocietyModel> societies = [];
  SocietyModel? selectedSociety;

  AuthenticationProvider(){
    loadSocieties();
  }
  void onPickImageTap()async{
    ImagePicker imagPicked = ImagePicker();
    pickedImage = await imagPicked.pickImage(source: .gallery);
    if(pickedImage != null){
      notifyListeners();
    }
  }

  Future<String?> onCreateAccountTap({required AppLocalizations localization,  required String email, required String name, required String password})async{
    if (selectedSociety == null) {
      return localization.selectSociety;
    }
    _isSigningUp = true;
    notifyListeners();
    try{
      await _authService.signup(name: name,
          email: email,
          password: password,
          societyID: selectedSociety!.id,
        image: pickedImage,
      );
      return null;
    }catch(e){
      return e.toString();
    }finally{
      _isSigningUp = false;
      notifyListeners();
    }
  }

  Future<void> loadSocieties() async{
    try{
      loadingSocieties = true;
      societiesError = null;
      notifyListeners();
     societies = await _authService.getSocieties();
      loadingSocieties = false;
      notifyListeners();
    }catch(e){
      societies = [];
      selectedSociety = null;
      loadingSocieties = false;
      societiesError = e.toString();
      notifyListeners();
    }
  }

  void onSelectSocietyTap(SocietyModel society){
    selectedSociety = society;
    notifyListeners();
  }

  Future<UserModel?> onLoginTap({required String email, required String password}) async{
    isSigningIn = true;
    notifyListeners();
    try{
      UserModel? result = await _authService.signIn(email: email, password: password,);
     return result;
    }catch(e){
      debugPrint("Error while sign in: ${e.toString()}");
      return null;
    }finally{
      _isSigningUp = false;
      isSigningIn = false;
      notifyListeners();
    }
  }
}
