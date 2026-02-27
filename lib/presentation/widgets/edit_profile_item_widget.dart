import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/helpers/formating_helper.dart';
import '../../core/res/app_icons.dart';
import '../../core/res/app_textstyles.dart';

class EditProfileItemWidget extends StatelessWidget {
  const EditProfileItemWidget({
    super.key,
    required String title, required String value, required VoidCallback onTap, List<String>? emergencyContacts, bool isPhone = false
  }): _title = title, _value = value, _onTap = onTap, _emergencyContacts = emergencyContacts, _isPhoneNum = isPhone;
  final String _title;
  final String _value;
  final VoidCallback _onTap;
  final List<String>? _emergencyContacts;
  final bool _isPhoneNum;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_title, style: AppTextStyles.editProfileHeadingTextStyle,),
              InkWell(onTap: _onTap, child: SvgPicture.asset(AppIcons.icProfileEdit))
            ],
          ),
          _emergencyContacts == null ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isPhoneNum ? FormatingHelper.formatPhoneNumber(_value) : _value, style: AppTextStyles.editProfileSubHeadingTextStyle,),
              Divider()
            ],
          ) : Column(
            spacing: 10,
            children: _emergencyContacts.map((contact){
              debugPrint("Contact: $contact");
              final decoded = jsonDecode(contact);
              if(decoded != null && decoded is List<dynamic>){
                debugPrint("Decoded: $decoded");
                List<dynamic> contactList = decoded;
                return Column(
                  children: contactList.map((contact){
                    final decodedContact = jsonDecode(contact);
                    String contactName = decodedContact['name'];
                    String contactNumber = decodedContact['mobile'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(contactName, style: AppTextStyles.emergencyContactTitleTextStyle,),
                        Text(FormatingHelper.formatPhoneNumber(contactNumber), style: AppTextStyles.editProfileSubHeadingTextStyle,),

                      ],
                    );
                  }).toList(),
                );
              }
              return Text(contact, style: AppTextStyles.editProfileSubHeadingTextStyle,);
              /*return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: AppTextStyles.emergencyContactTitleTextStyle,),
                  Text(contact.phoneNumber, style: AppTextStyles.editProfileSubHeadingTextStyle,)
                ],
              );*/
            }).toList(),
          )


        ],
      ),
    );
  }
}