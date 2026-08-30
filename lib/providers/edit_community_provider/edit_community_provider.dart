import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/society_model.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/services/admin_transfer_service/admin_transfer_service.dart';
import 'package:portalixmx_resident_admin/services/residents_service/residents_service.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';

class EditUpdateCommunityProvider extends ChangeNotifier {
  final _residentService = ResidentsService.instance;
  final _transferService = AdminTransferService.instance;
  bool loadingSociety = false;
  String? error;
  SocietyModel? society;
  UserModel? currentAdmin;

  XFile? pickedImage;

  bool updatingSociety = false;

  bool get isOwner {
    if (currentAdmin == null || society == null) return false;
    return _transferService.canManageSociety(
      callerUid: currentAdmin!.userID,
      society: society!,
    );
  }

  EditUpdateCommunityProvider() {
    _initSocietyInfo();
  }

  void _initSocietyInfo() async {
    loadingSociety = true;
    notifyListeners();
    try {
      currentAdmin = await UserService.instance.getCurrentUser();
      if (currentAdmin == null) {
        error = 'User not found';
        society = null;
      } else {
        society = await _residentService.getSocietyByID(
          societyID: currentAdmin!.societyID,
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loadingSociety = false;
      notifyListeners();
    }
  }

  Future<String?> updateSociety({
    required String name,
    required String address,
  }) async {
    updatingSociety = true;
    notifyListeners();
    try {
      if (currentAdmin == null) throw Exception('User not found');
      if (society == null) throw Exception('Society not found');
      if (!isOwner) throw Exception('You are not the owner of this society');

      String? imageUrl = society?.imageUrl;
      if (pickedImage != null) {
        imageUrl = await _residentService.uploadImage(
          selectedImageFile: pickedImage!,
          societyID: currentAdmin!.societyID,
        );
      }
      final updated = society!.copyWith(name: name, location: address, imageUrl: imageUrl);
      await _residentService.updateSociety(society: updated);
      society = updated;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      updatingSociety = false;
      notifyListeners();
    }
  }

  void onEditProfilePictureTap() async{
    ImagePicker imagePicker = ImagePicker();
   XFile? image = await imagePicker.pickImage(source: .gallery);
   if(image != null){
     pickedImage = image;
     notifyListeners();
   }
  }


}
