import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/res/app_colors.dart' show AppColors;
import '../../core/res/app_textstyles.dart';
import '../widgets/primary_btn.dart';

class AccessCodeGeneratedDialog extends StatelessWidget{
  const AccessCodeGeneratedDialog({super.key, required this.accessCode});
  final String accessCode;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: .all(15), child: Column(
      mainAxisSize: .min,
      spacing: 16,
      children: [
        Align(
            alignment: .topLeft,
            child: Text("Access Code", style: AppTextStyles.regularTextStyle.copyWith(color: Colors.black),)),
        Text(accessCode, style: AppTextStyles.headingTextStyle.copyWith(color: AppColors.primaryColor, fontSize: 32),),
        SizedBox(
          width: .infinity,
          child: PrimaryBtn(onTap: ()=> Navigator.pop(context, {'code' : accessCode}), btnText: "Share Code",),
        ),
        SizedBox(
          width: .infinity,
          child: PrimaryBtn(onTap: ()=> Navigator.pop(context, {'changeCode' : true}), btnText: "Change Code", bgColor: Colors.white, textColor: AppColors.primaryColor,),
        ),
        Row(
          spacing: 14,
          children: [
            Expanded(child: Divider(color: AppColors.lightGreyBackgroundColor,)),
            Text("OR"),
            Expanded(child: Divider(color: AppColors.lightGreyBackgroundColor,))
          ],
        ),
        _buildQRImage(),
        TextButton(onPressed: ()=> _shareQrCode(context), child: Text("Share QR Code")),
        Align(
          alignment: .topRight,
          child: TextButton(onPressed: ()=> Navigator.pop(context), child: Text("Cancel", style: AppTextStyles.regularTextStyle.copyWith(color: Colors.red),)),
        )
      ],
    ),);
  }

  Widget _buildQRImage({bool comingForScreenshot = false}) {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    final map = {
      'accessCode': accessCode,
      'createdByUserID': currentUID,
    };
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const .all(10.0),
        child: SizedBox(
          height: comingForScreenshot ? 200 : 100,
          child: QrImageView(data: jsonEncode(map)),
        ),
      ),
    );
  }

  void _shareQrCode(BuildContext context) async {
    try {
      Uint8List? capturedImage = await _takeScreenshot(context);
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/accessCode.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(capturedImage!);
      Navigator.pop(context, {'qrCodeImagePath': imagePath});
    } catch (e) {
      debugPrint("Failed to share QR Code: ${e.toString()}");
    }
  }

  Future<Uint8List?> _takeScreenshot(BuildContext context) async {
    Uint8List? uint8List;
    ScreenshotController screenshotController = ScreenshotController();

    try {
      uint8List = await screenshotController.captureFromWidget(
        _buildQRImage(),
        delay: const Duration(seconds: 1),
      );
    } catch (e) {
      debugPrint('Error while taking screenshot: ${e.toString()}');
    }
    return uint8List;
  }
}