import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/res/app_colors.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/profile_provider.dart';
import '../../widgets/app_textfield_widget.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/primary_btn.dart';
import '../../widgets/profile_image_widget.dart';

class EditProfilePage extends StatefulWidget{
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = .new();
  final TextEditingController _phoneNumController = .new();

  late ProfileProvider provider;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      if(provider.user != null){
        _nameController.text = provider.user!.userName;
        _phoneNumController.text = provider.user!.phoneNum ?? '';
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    provider = Provider.of<ProfileProvider>(context);
    return BgGradientScreen(child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 65.0),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              BackButton(color: Colors.white,),
              Text(AppLocalizations.of(context)!.profile, style: AppTextStyles.regularTextStyle,),
              const SizedBox(width: 40,)
            ],
          ),
        ),

        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                    top: 65,
                    right: 0,
                    left: 0,
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      child: SizedBox(
                          height: size.height*0.8,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(top: 100, right: 15, left: 15,),
                            child: Column(
                              crossAxisAlignment: .start,
                              spacing: 20,
                              children: [
                                Column(
                                  spacing: 10,
                                  children: [
                                    AppTextField(title: 'Name', hintText: 'Name', controller: _nameController,titleTextStyle: AppTextStyles.editProfileHeadingTextStyle, isDense: true, borderColor: AppColors.lightGreyBackgroundColor,),
                                    AppTextField(title: 'Phone', hintText: 'Phone Number', controller: _phoneNumController,titleTextStyle: AppTextStyles.editProfileHeadingTextStyle, textInputType: .number, isDense: true, borderColor: AppColors.lightGreyBackgroundColor,),
                                  ],
                                ),
                              Padding(
                                padding: EdgeInsets.only(top: 40,bottom: size.height*0.07),
                                child: Consumer<ProfileProvider>(
                                    builder: (context, provider,  _) {
                                      return SizedBox(
                                        height: 50,
                                        width: .infinity,
                                        child: PrimaryBtn(onTap: _onUpdateTap, btnText: AppLocalizations.of(context)!.update, isLoading: provider.updatingProfile,),
                                      );
                                    }
                                ),)
                              ],
                            ),
                          )
                        ),
                    )),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: provider.onPickImageTap,
                    child: ProfileImageWidget(imageUrl: provider.pickedImage != null ? provider.pickedImage!.path : provider.user!.profileImg, isLocalFile: provider.pickedImage != null,)
                ),)
              ],
            ),
          ),
        )
      ],
    ));
  }

  Future<void> _onUpdateTap() async {
    String name = _nameController.text.trim();
    String phone = _phoneNumController.text.trim();
    if(name.isEmpty){
      Fluttertoast.showToast(msg: "Name cannot be empty, Please enter your name");
      return;
    }

    String? isError = await provider.onUpdateTap(name: name, phoneNum: phone, );
    if(isError != null){
      Fluttertoast.showToast(msg: isError);
      return;
    }

    context.pop();
  }
}