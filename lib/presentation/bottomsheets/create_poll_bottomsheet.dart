import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_icons.dart';
import '../../core/res/app_textstyles.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_textfield_widget.dart';
import '../widgets/primary_btn.dart';

class CreatePollBottomSheet extends StatefulWidget {
  const CreatePollBottomSheet({super.key});

  @override
  State<CreatePollBottomSheet> createState() => _CreatePollBottomSheetState();
}

class _CreatePollBottomSheetState extends State<CreatePollBottomSheet> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  XFile? _image;

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text(l.createPoll, style: AppTextStyles.bottomSheetHeadingTextStyle),
              const SizedBox(height: 10),
              AppTextField(
                controller: _questionController,
                hintText: l.pollQuestion,
                fillColor: AppColors.fillColorGrey,
              ),
              ...List.generate(_optionControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _optionControllers[index],
                        hintText: 'Option ${index + 1}',
                        fillColor: AppColors.fillColorGrey,
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _optionControllers[index].dispose();
                            _optionControllers.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _optionControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(l.addOption),
              ),
              Row(
                spacing: 20,
                children: [
                  Expanded(child: _buildUploadWidget(title: l.uploadPhotos, icon: AppIcons.icUploadPhotos, onTap: _onUploadTap)),
                  Expanded(child: _buildUploadWidget(title: l.openCamera, icon: AppIcons.icCamera, onTap: _onCameraTap)),
                ],
              ),
              if (_image != null)
                Row(
                  children: [
                    Expanded(child: Text(_image!.path.split('/').last, style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor))),
                    IconButton(
                      onPressed: () {
                        setState(() => _image = null);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: PrimaryBtn(onTap: _onSubmitTap, btnText: l.submit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadWidget({required String title, required String icon, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.fillColorGrey,
        elevation: 0,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Column(
        spacing: 12,
        children: [
          SvgPicture.asset(icon),
          Text(title, style: AppTextStyles.hintTextStyle.copyWith(fontWeight: FontWeight.w400, color: const Color(0xff777777))),
        ],
      ),
    );
  }

  Future<void> _onUploadTap() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _image = file);
  }

  Future<void> _onCameraTap() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() => _image = file);
  }

  void _onSubmitTap() {
    final question = _questionController.text.trim();
    final options = _optionControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (question.isEmpty || options.length < 2) {
      return;
    }
    Navigator.pop(context, {'question': question, 'options': options, 'image': _image});
  }
}
