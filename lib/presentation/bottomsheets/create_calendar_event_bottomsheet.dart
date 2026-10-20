import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/common_ui.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_icons.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/from_date_and_time_widget.dart';
import '../widgets/primary_btn.dart';

class CreateCalendarEventBottomSheet extends StatefulWidget{
  const CreateCalendarEventBottomSheet({super.key});

  @override
  State<CreateCalendarEventBottomSheet> createState() => _CreateCalendarEventBottomSheetState();
}

class _CreateCalendarEventBottomSheetState extends State<CreateCalendarEventBottomSheet> {
  final TextEditingController _eventTitleTextEditingController = .new();
  final TextEditingController _eventDescriptionTextEditingController = .new();

  XFile? image;
  DateTime? _eventDate;

  TimeOfDay? _eventTime;
  @override
  void dispose() {
    _eventTitleTextEditingController.dispose();
    _eventDescriptionTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const .symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          spacing: 15,
          mainAxisSize: .min,
          children: [
            Text(localization.createEvent, style: AppTextStyles.bottomSheetHeadingTextStyle,),
            const SizedBox(height: 10,),
            AppTextField(controller: _eventTitleTextEditingController, hintText: localization.eventTitle, fillColor: AppColors.fillColorGrey,),
            AppTextField(controller: _eventDescriptionTextEditingController, hintText: localization.eventDescription, fillColor: AppColors.fillColorGrey, maxLines: 5,),

            FromDateAndTimeWidget(title: localization.eventDateAndTime,onDateTap: _onFromDateTap, onTimeTap: _onFromTimeTap, selectedDate: _eventDate, selectedTime: _eventTime),
            // FromDateAndTimeWidget(title: localization.to,onDateTap: _onToDateTap, onTimeTap: _onToTimeTap, selectedDate: _selectedToDateTime, selectedTime: _selectedToTime),
            Row(
              spacing: 20,
              children: [
                Expanded(child: _buildUploadPicturesWidget(title: localization.uploadPhotos, icon: AppIcons.icUploadPhotos, onTap: _onUploadPhotosTap)),
                Expanded(child: _buildUploadPicturesWidget(title: localization.openCamera, icon: AppIcons.icCamera, onTap: _onOpenCameraTap)),
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
              padding: const .symmetric(vertical: 18.0),
              child: SizedBox(
                height: 50,
                width: .infinity,
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

  void _onFromDateTap() async {
    _eventDate = await showDatePicker(context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (_eventDate != null) {
      setState(() {});
    }
  }
  void _onFromTimeTap()async{
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if(pickedTime != null){
      setState(() =>  _eventTime = pickedTime);
    }
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

  void _onSubmitTap() {
    final title = _eventTitleTextEditingController.text.trim();
    final description = _eventDescriptionTextEditingController.text.trim();

    if (title.isEmpty) {
      CommonUI.showSnackBarMessage(context, isError: true, message: 'Please enter an event title');
      return;
    }
    if (_eventDate == null || _eventTime == null) {
      CommonUI.showSnackBarMessage(context, isError: true, message: 'Please select event date and time');
      return;
    }

    Navigator.pop(context, {
      'eventTitle': title,
      'eventDescription': description,
      'image': image,
      'eventDate': _eventDate,
      'eventTime': _eventTime,
    });
  }
}