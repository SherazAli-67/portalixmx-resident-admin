import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/common_ui.dart';
import '../../core/models/access_model.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/primary_btn.dart';

class AddAccessBottomSheet extends StatefulWidget {
  const AddAccessBottomSheet({super.key, this.existingAccess});

  final AccessModel? existingAccess;

  @override
  State<AddAccessBottomSheet> createState() => _AddAccessBottomSheetState();
}

class _AddAccessBottomSheetState extends State<AddAccessBottomSheet> {
  final TextEditingController _titleTextEditingController = .new();
  XFile? _selectedAccessImage;
  String? _existingImageUrl;
  bool _freeToUse = false;

  @override
  void initState() {
    super.initState();
    final access = widget.existingAccess;
    if (access != null) {
      _titleTextEditingController.text = access.name;
      _freeToUse = access.freeToUse;
      if (access.image.startsWith('http')) {
        _existingImageUrl = access.image;
      }
    }
  }

  @override
  void dispose() {
    _titleTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isEditing = widget.existingAccess != null;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          spacing: 15,
          mainAxisSize: .min,
          children: [
            Text(localization.access, style: AppTextStyles.bottomSheetHeadingTextStyle),
            GestureDetector(
              onTap: _onPickImageTap,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: _selectedAccessImage != null
                    ? FileImage(File(_selectedAccessImage!.path)) as ImageProvider
                    : (_existingImageUrl != null ? NetworkImage(_existingImageUrl!) : null),
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                child: _selectedAccessImage == null && _existingImageUrl == null
                    ? Icon(Icons.add_a_photo_outlined, color: AppColors.primaryColor)
                    : null,
              ),
            ),
            AppTextField(
              controller: _titleTextEditingController,
              hintText: localization.title,
              fillColor: AppColors.fillColorGrey,
              maxLines: 5,
            ),
            Row(
              children: [
                Expanded(child: Text(localization.freeToUse, style: AppTextStyles.tileTitleTextStyle)),
                CupertinoSwitch(value: _freeToUse, onChanged: (_) => toggleFreeToUse()),
              ],
            ),
            Padding(
              padding: const .symmetric(vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: PrimaryBtn(
                  onTap: _onAddAccessTap,
                  btnText: isEditing ? localization.update : localization.submit,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  void _onAddAccessTap() {
    final access = _titleTextEditingController.text.trim();
    if (access.isEmpty) {
      CommonUI.showSnackBarMessage(context, isError: true, message: 'Please enter a title');
      return;
    }
    if (_selectedAccessImage == null && _existingImageUrl == null) {
      CommonUI.showSnackBarMessage(context, isError: true, message: 'Please select an image');
      return;
    }
    Navigator.pop(context, {
      'access': access,
      'image': _selectedAccessImage,
      'existingImageUrl': _existingImageUrl,
      'freeToUse': _freeToUse,
    });
  }

  void _onPickImageTap() async {
    _selectedAccessImage = await ImagePicker().pickImage(source: .gallery);
    if (_selectedAccessImage != null) setState(() {});
  }

  void toggleFreeToUse() {
    setState(() => _freeToUse = !_freeToUse);
  }
}
