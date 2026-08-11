import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_icons.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/datetime_format_helpers.dart';
import '../widgets/primary_btn.dart';
import '../widgets/vistor_info_item_widget.dart';

class SubmitPaymentToAdminBottomSheet extends StatefulWidget{
  const SubmitPaymentToAdminBottomSheet({super.key, required this.payment});
  final PaymentModel payment;
  @override
  State<SubmitPaymentToAdminBottomSheet> createState() => _SubmitPaymentToAdminBottomSheetState();
}

class _SubmitPaymentToAdminBottomSheetState extends State<SubmitPaymentToAdminBottomSheet> {

  XFile? image;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 16.0, vertical: 25),
        child: Column(
          spacing: 15,
          children: [
            Text(localizations.paymentDetails, style: AppTextStyles.bottomSheetHeadingTextStyle,),
            const SizedBox(height: 10,),
            Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child:VisitorInfoItemWidget(title: localizations.paymentFor, subTitle: widget.payment.paymentForTitle,),

                    ),
                    Expanded(
                        child: VisitorInfoItemWidget(
                            title: localizations.amount, subTitle: '${ widget.payment.amount}')
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: VisitorInfoItemWidget(title: localizations.date, subTitle: DateTimeFormatHelpers.formatDateTime( widget.payment.dateTime), showDivider:  widget.payment.paymentStatus ==.received ),),
                    Expanded(
                        child: VisitorInfoItemWidget(
                          title: localizations.status, subTitle: widget.payment.paymentStatus.name.toUpperCase(),)
                    ),
                  ],
                ),
              ],
            ),
            Align(
                alignment: .topLeft,
                child: Text(localizations.receipt, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.primaryColor),)),

            Row(
              spacing: 20,
              children: [
                Expanded(child: _buildUploadPicturesWidget(title: localizations.uploadPhotos, icon: AppIcons.icUploadPhotos, onTap: _onUploadPhotosTap)),
                Expanded(child: _buildUploadPicturesWidget(title: localizations.openCamera, icon: AppIcons.icCamera, onTap: _onOpenCameraTap)),
              ],
            ),
            if(image != null)
              Row(
                children: [
                  Expanded(child: Text(image!.path.split('/').last, style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),)),
                  IconButton(onPressed: (){
                    image = null;
                    setState(() {});
                  }, icon: Icon(Icons.delete))
                ],
              ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: PrimaryBtn(onTap: _onSubmitTap, btnText: localizations.submit,),
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
    image = await imagePicker.pickImage(source: .gallery);
    if(image != null){
      setState(() {});
    }
  }

  void _onOpenCameraTap()async{
    final imagePicker = ImagePicker();
    image = await imagePicker.pickImage(source: .camera);
    if(image != null){
      setState(() {});
    }
  }

  void _onSubmitTap()async{
    if(image == null){
      Navigator.pop(context);
    }else{
      Navigator.pop(context, {'receipt' : image,});
    }
  }
}