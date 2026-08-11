import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/primary_btn.dart';

class AddAccessBottomSheet extends StatefulWidget{
  const AddAccessBottomSheet({super.key});

  @override
  State<AddAccessBottomSheet> createState() => _AddAccessBottomSheetState();
}

class _AddAccessBottomSheetState extends State<AddAccessBottomSheet> {
  final TextEditingController _titleTextEditingController = .new();
  XFile? _selectedAccessImage;
  bool _freeToUse = false;
  @override
  void dispose() {
    _titleTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 16.0, vertical: 25),
        child: Column(
          spacing: 15,
          children: [
            Text(AppLocalizations.of(context)!.access, style: AppTextStyles.bottomSheetHeadingTextStyle,),
            GestureDetector(
              onTap: _onPickImageTap,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: _selectedAccessImage != null ? FileImage(File(_selectedAccessImage!.path)) : null,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 10,),
            AppTextField(controller: _titleTextEditingController, hintText: AppLocalizations.of(context)!.title, fillColor: AppColors.fillColorGrey, maxLines: 5,),
            Row(
              children: [
                Expanded(child: Text(localization.freeToUse, style: AppTextStyles.tileTitleTextStyle,)),
                CupertinoSwitch(value: _freeToUse, onChanged: (val)=> toggleFreeToUse())
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: PrimaryBtn(onTap: _onAddAccessTap, btnText: AppLocalizations.of(context)!.submit,),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onAddAccessTap()async{
    String access = _titleTextEditingController.text.trim();
    Navigator.pop(context, {'access' : access, 'image' : _selectedAccessImage!.path});
  }

  void _onPickImageTap() async{
    _selectedAccessImage = await ImagePicker().pickImage(source: .gallery);
    if(_selectedAccessImage != null) setState(()=> {});
  }

  void toggleFreeToUse(){
    setState(() => _freeToUse = !_freeToUse);
  }
}