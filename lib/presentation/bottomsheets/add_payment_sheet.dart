import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_icons.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/primary_btn.dart';

class AddPaymentSheet extends StatefulWidget{
  const AddPaymentSheet({super.key});

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet> {
  final TextEditingController _paymentForController = .new();
  final TextEditingController _descriptionController = .new();
  final TextEditingController _amountController = .new();

  final List<XFile> _pickedImages =  [];

  @override
  void dispose() {
    _paymentForController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
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
            Text(localization.paymentDetails, style: AppTextStyles.bottomSheetHeadingTextStyle,),
            const SizedBox(height: 10,),
            AppTextField(controller: _paymentForController, hintText: localization.paymentFor, fillColor: AppColors.fillColorGrey,),
            AppTextField(controller: _descriptionController, hintText: localization.description, fillColor: AppColors.fillColorGrey,),
            AppTextField(controller: _amountController, hintText: localization.amount, fillColor: AppColors.fillColorGrey, textInputType: .number,),
            Align(
                alignment: .topLeft,
                child: Text(localization.receipt, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.primaryColor),)),

            Row(
              spacing: 20,
              children: [
                Expanded(child: _buildUploadPicturesWidget(title: localization.uploadPhotos, icon: AppIcons.icUploadPhotos, onTap: _onUploadPhotosTap)),
                Expanded(child: _buildUploadPicturesWidget(title: localization.openCamera, icon: AppIcons.icCamera, onTap: _onOpenCameraTap)),
              ],
            ),
            Column(
              children: _pickedImages.map((image) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(image.path.split('/').last, style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),)),
                      IconButton(onPressed: (){
                        _pickedImages.remove(image);
                        setState(() {});
                      }, icon: Icon(Icons.delete))
                    ],
                  ),
                /*  if(index != _pickedImages.length-1)
                    Divider()*/
                ],
              )).toList(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: PrimaryBtn(onTap: _onSubmitTap, btnText: localization.submit,),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPicturesWidget({required String title, required VoidCallback onTap, required String icon}) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.fillColorGrey,
            elevation: 0,
            padding: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )
        ),
        onPressed: onTap, child: Column(
      spacing: 12,
      children: [
        SvgPicture.asset(icon),
        Text(title, style: AppTextStyles.hintTextStyle.copyWith(
            fontWeight: FontWeight.w400, color: Color(0xff777777)),)
      ],
    ));
  }

  void _onUploadPhotosTap()async{
    final imagePicker = ImagePicker();
    List<XFile> pickedFiles = await imagePicker.pickMultiImage();
    if(pickedFiles.isNotEmpty){
      _pickedImages.addAll(pickedFiles) ;
      setState(() {});
    }
  }

  void _onOpenCameraTap()async{
    final imagePicker = ImagePicker();
    XFile? pickedFiles = await imagePicker.pickImage(source: ImageSource.camera);
    if(pickedFiles != null){
      _pickedImages.add(pickedFiles) ;
      setState(() {});
    }
  }

  void _onSubmitTap()async{
    String paymentFor = _paymentForController.text.trim();
    String description = _descriptionController.text.trim();
    String amount = _amountController.text.trim();
    if(paymentFor.isEmpty && _pickedImages.isEmpty){
      Navigator.pop(context);
    }else{
      Navigator.pop(context, {'paymentFor' : paymentFor, 'description' : description, 'amount' :  amount, 'receipts' : _pickedImages});
    }
  }
}