import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _formError;

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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const .symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                spacing: 15,
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
                  if (_formError != null)
                    Align(
                      alignment: .centerLeft,
                      child: Text(
                        _formError!,
                        style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: .infinity,
                child: PrimaryBtn(
                  onTap: _onAddAccessTap,
                  btnText: isEditing ? localization.update : localization.submit,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddAccessTap() {
    final localization = AppLocalizations.of(context)!;
    final access = _titleTextEditingController.text.trim();
    if (access.isEmpty) {
      setState(() => _formError = localization.pleaseEnterTitle);
      return;
    }
    if (_selectedAccessImage == null && _existingImageUrl == null) {
      setState(() => _formError = localization.pleaseSelectImage);
      return;
    }
    setState(() => _formError = null);
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
