import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../core/app_data/app_data.dart';
import '../../core/models/day_time_model.dart';
import '../../core/models/visitor_model.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/datetime_format_helpers.dart';
import '../../providers/home_provider.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/drop_down_textfield_widget.dart';
import '../widgets/from_date_and_time_widget.dart';
import '../widgets/primary_btn.dart';

class AddUpdateGuestBottomSheet extends StatefulWidget{
  const AddUpdateGuestBottomSheet({
    super.key, 
    this.visitor,
    this.isEdit = false,
    this.comingFromGuestDirectory = false
  });
  
  final BaseVisitor? visitor;
  final bool isEdit;
  final bool comingFromGuestDirectory;
  @override
  State<AddUpdateGuestBottomSheet> createState() => _AddUpdateGuestBottomSheetState();
}

class _AddUpdateGuestBottomSheetState extends State<AddUpdateGuestBottomSheet> {
  final TextEditingController _nameController = .new();
  final TextEditingController _contactNumberController = .new();
  final TextEditingController _accessFor = .new();
  final TextEditingController _carPlatNumberController = .new();
  final TextEditingController _vehicleModelController = .new();
  final TextEditingController _colorController = .new();

  List<String> _guestTypes = [];
  int selectedGuestTypeIndex = 1;
  DateTime? _selectedFromDateTime;
  DateTime? _selectedToDateTime;

  TimeOfDay? _selectedFromTime;
  TimeOfDay? _selectedToTime;

  List<DayTimeModel> _regularVisitorTime = [];
  
  @override
  void initState() {
    _regularVisitorTime = List.generate(7, (index) => DayTimeModel(dayID: index));

    if (widget.visitor != null) {
      final visitor = widget.visitor!;
      
      if (visitor is GuestVisitor) {
        selectedGuestTypeIndex = 1; // Guest
        _nameController.text = visitor.name;
        _contactNumberController.text = visitor.contact;
        _accessFor.text = visitor.accessFor ?? '';
        _carPlatNumberController.text = visitor.vehicleInfo.plateNumber;
        _vehicleModelController.text = visitor.vehicleInfo.model;
        _colorController.text = visitor.vehicleInfo.color;
        
        _selectedFromDateTime = visitor.fromDateTime;
        _selectedToDateTime = visitor.toDateTime;
        _selectedFromTime = TimeOfDay.fromDateTime(visitor.fromDateTime);
        _selectedToTime = TimeOfDay.fromDateTime(visitor.toDateTime);
      } else if (visitor is RegularVisitor) {
        selectedGuestTypeIndex = 0; // Regular Visitor
        _nameController.text = visitor.name;
        _contactNumberController.text = visitor.contact;
        _accessFor.text = visitor.accessFor ?? '';
        _carPlatNumberController.text = visitor.vehicleInfo.plateNumber;
        _vehicleModelController.text = visitor.vehicleInfo.model;
        _colorController.text = visitor.vehicleInfo.color;
        
        final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
        for (int i = 0; i < days.length; i++) {
          final schedule = visitor.schedule[days[i]];
          if (schedule != null) {
            _regularVisitorTime[i].time = schedule.startTime;
            _regularVisitorTime[i].endTime = schedule.endTime;
          }
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _guestTypes = [
        AppLocalizations.of(context)!.regularVisitor, 
        AppLocalizations.of(context)!.guest
      ];
      setState(() {});
    });
    super.initState();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _accessFor.dispose();
    _carPlatNumberController.dispose();
    _vehicleModelController.dispose();
    _colorController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            Align(
                alignment: Alignment.center,
                child: Text(widget.isEdit
                    ? localization.editGuest
                    : localization.addGuest, style: TextStyle(fontSize: 20, fontWeight: .w700, color: AppColors.primaryColor),)),
            AppTextField(controller: _nameController,
              hintText: localization.name,
              fillColor: AppColors.fillColorGrey,
              hintTextColor: AppColors.hintTextColor,
              borderColor: AppColors.borderColor,),
            if(_guestTypes.isNotEmpty)
              DropdownTextFieldWidget(isEmpty: selectedGuestTypeIndex == -1,
                  selectedValue: _guestTypes[selectedGuestTypeIndex],
                  onChanged: (val) => setState(() => selectedGuestTypeIndex = _guestTypes.indexOf(val!)),
                  guestTypes: _guestTypes,
                  hintText: localization.guest),
            AppTextField(controller: _contactNumberController,
              hintText: localization.contactNum,
              fillColor: AppColors.fillColorGrey,
              hintTextColor: AppColors.hintTextColor,
              borderColor: AppColors.borderColor,
              textInputType: .numberWithOptions(),),
            AppTextField(controller: _accessFor,
              hintText: localization.accessFor,
              fillColor: AppColors.fillColorGrey,
              hintTextColor: AppColors.hintTextColor,
              borderColor: AppColors.borderColor,),
            AppTextField(controller: _carPlatNumberController, hintText: localization.carPlateNumber, fillColor: AppColors.fillColorGrey, hintTextColor: AppColors.hintTextColor,borderColor: AppColors.borderColor,),
            AppTextField(controller: _vehicleModelController, hintText: localization.vehicleModel, fillColor: AppColors.fillColorGrey, hintTextColor: AppColors.hintTextColor,borderColor: AppColors.borderColor,),
            AppTextField(controller: _colorController, hintText: localization.color, fillColor: AppColors.fillColorGrey, hintTextColor: AppColors.hintTextColor,borderColor: AppColors.borderColor,),
            selectedGuestTypeIndex == 0
                ? _buildRegularVisitorWidget(localization)
                : _buildGuestWidget(localization),
      
            Consumer<HomeProvider>(builder: (ctx, provider, _) {
              return SizedBox(
                height: 50,
                width: .infinity,
                child: PrimaryBtn(onTap: _onSubmitTap, btnText: localization.submit,),
              );
            })
          ],
        ),
      ),
    );
  }



  void _onFromDateTap() async {
    _selectedFromDateTime = await showDatePicker(context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (_selectedFromDateTime != null) {
      setState(() {});
    }
  }
  void _onFromTimeTap()async{
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if(pickedTime != null){
      setState(() =>  _selectedFromTime = pickedTime);
    }
  }

  void _onToDateTap()async{
    _selectedToDateTime = await showDatePicker(context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (_selectedToDateTime != null) {
      setState(() {});
    }
  }
  void _onToTimeTap()async{
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if(pickedTime != null){
      setState(() =>  _selectedToTime = pickedTime);
    }
  }

  Widget _buildGuestWidget(AppLocalizations localization) {
    return Column(
      spacing: 15,
      children: [
        FromDateAndTimeWidget(title: localization.from,onDateTap: _onFromDateTap, onTimeTap: _onFromTimeTap, selectedDate: _selectedFromDateTime, selectedTime: _selectedFromTime),
        FromDateAndTimeWidget(title: localization.to,onDateTap: _onToDateTap, onTimeTap: _onToTimeTap, selectedDate: _selectedToDateTime, selectedTime: _selectedToTime),
      ],
    );
  }

  Widget _buildRegularVisitorWidget(AppLocalizations localization) {
    return Column(
      spacing: 15,
      children: List.generate(_regularVisitorTime.length, (index){
        int dayID = _regularVisitorTime[index].dayID;
        TimeOfDay? time = _regularVisitorTime[index].time;
        TimeOfDay? endTime = _regularVisitorTime[index].endTime;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(AppData.getDayByID(context, dayID), style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),),
            Row(
              spacing: 20,
              children: [
                Expanded(child: Container(
                    padding: EdgeInsets.only(left: 15, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        color: AppColors.fillColorGrey,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(time != null ? DateTimeFormatHelpers.formatTime(time) : localization.time, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.greyColor2),),
                        IconButton(onPressed: ()=> onTimeTap(index), icon: Icon(Icons.access_time, color: AppColors.darkGreyColor2,))
                      ],
                    )
                )),
                Expanded(child: Container(
                    padding: EdgeInsets.only(left: 15, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        color: AppColors.fillColorGrey,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(endTime != null ? DateTimeFormatHelpers.formatTime(endTime) : localization.time, style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.greyColor2),),
                        IconButton(onPressed: ()=> onEndTimeTap(index), icon: Icon(Icons.access_time, color: AppColors.darkGreyColor2,))
                      ],
                    )
                ))
              ],
            )
          ],
        );
      }),
    );
  }
  
  void onTimeTap(int index)async{
    TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if(pickedTime != null){
      _regularVisitorTime[index].time = pickedTime;
      setState(() {});
    }
  }

  void onEndTimeTap(int index)async{
    TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if(pickedTime != null){
      _regularVisitorTime[index].endTime = pickedTime;
      setState(() {});
    }
  }

  Future<void> _onSubmitTap() async {
  }

  bool _validateInputs(AppLocalizations localization) {
    if (_nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: localization.pleaseEnterName);
      return false;
    }
    
    if (_contactNumberController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: localization.pleaseEnterContactNumber);
      return false;
    }
    
    if (_carPlatNumberController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: localization.pleaseEnterCarPlateNumber);
      return false;
    }
    
    if (_vehicleModelController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: localization.pleaseEnterVehicleModel);
      return false;
    }
    
    if (_colorController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: localization.pleaseEnterColor);
      return false;
    }
    
    // Guest-specific validation
    if (selectedGuestTypeIndex == 1) {
      if (_selectedFromDateTime == null || _selectedFromTime == null) {
        Fluttertoast.showToast(msg: localization.pleaseSelectFromDateTime);
        return false;
      }
      
      if (_selectedToDateTime == null || _selectedToTime == null) {
        Fluttertoast.showToast(msg: localization.pleaseSelectToDateTime);
        return false;
      }
      
      final fromDateTime = _combineDateTime(_selectedFromDateTime!, _selectedFromTime!);
      final toDateTime = _combineDateTime(_selectedToDateTime!, _selectedToTime!);
      
      if (toDateTime.isBefore(fromDateTime)) {
        Fluttertoast.showToast(msg: localization.toDateTimeMustBeAfterFromDateTime);
        return false;
      }
    } else {
      // Regular visitor validation - at least one day should have time set
      bool hasAtLeastOneDay = _regularVisitorTime.any((day) => day.time != null && day.endTime != null);
      if (!hasAtLeastOneDay) {
        Fluttertoast.showToast(msg: localization.pleaseSelectAtLeastOneDay);
        return false;
      }
    }
    
    return true;
  }

  GuestVisitor _createGuestVisitor() {
    final now = DateTime.now();
    final fromDateTime = _combineDateTime(_selectedFromDateTime!, _selectedFromTime!);
    final toDateTime = _combineDateTime(_selectedToDateTime!, _selectedToTime!);

    return GuestVisitor(
      id: widget.visitor?.id ?? '',
      // code: code,
      name: _nameController.text.trim(),
      contact: _contactNumberController.text.trim(),
      accessFor: _accessFor.text.trim().isEmpty ? null : _accessFor.text.trim(),
      vehicleInfo: VehicleInfo(
        plateNumber: _carPlatNumberController.text.trim(),
        model: _vehicleModelController.text.trim(),
        color: _colorController.text.trim(),
      ),
      fromDateTime: fromDateTime,
      toDateTime: toDateTime,
      createdAt: widget.visitor?.createdAt ?? now,
      updatedAt: now,
    );
  }

  RegularVisitor _createRegularVisitor() {
    final now = DateTime.now();
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final schedule = <String, VisitorSchedule?>{};

    for (int i = 0; i < days.length; i++) {
      final dayTime = _regularVisitorTime[i];
      if (dayTime.time != null && dayTime.endTime != null) {
        schedule[days[i]] = VisitorSchedule(
          startTime: dayTime.time!,
          endTime: dayTime.endTime!,
        );
      } else {
        schedule[days[i]] = null;
      }
    }

    return RegularVisitor(
      id: widget.visitor?.id ?? '',
      // code: code,
      name: _nameController.text.trim(),
      contact: _contactNumberController.text.trim(),
      accessFor: _accessFor.text.trim().isEmpty ? null : _accessFor.text.trim(),
      vehicleInfo: VehicleInfo(
        plateNumber: _carPlatNumberController.text.trim(),
        model: _vehicleModelController.text.trim(),
        color: _colorController.text.trim(),
      ),
      schedule: schedule,
      createdAt: widget.visitor?.createdAt ?? now,
      updatedAt: now,
    );
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String getFormattedTime(DayTimeModel time) {
    return jsonEncode(time.toJson());
  }
}

