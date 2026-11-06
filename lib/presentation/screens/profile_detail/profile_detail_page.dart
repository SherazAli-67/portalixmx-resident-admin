import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/app_textfield_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/providers/datetime_format_helpers.dart';
import 'package:portalixmx_resident_admin/providers/home_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_textstyles.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/vistor_info_item_widget.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key, required this.resident});
  final UserModel resident;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late final TextEditingController _houseNumberController;
  String? _houseNumberError;

  @override
  void initState() {
    super.initState();
    _houseNumberController = TextEditingController(text: widget.resident.houseNumber ?? '');
  }

  @override
  void dispose() {
    _houseNumberController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final resident = widget.resident;
    final houseNumber = resident.houseNumber?.trim();
    return BgGradientScreen(
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const .only(top: 65),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                BackButton(color: Colors.white),
                Expanded(
                  child: Text(
                    resident.userName,
                    textAlign: .center,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: AppTextStyles.regularTextStyle,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 0,
              margin: .zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const .only(top: 36.0, left: 18, right: 18, bottom: 16),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          _buildInformationItemWidget(
                            firstTitle: localization.name,
                            firstValue: resident.userName,
                            secondTitle: localization.joinedOn,
                            secondValue: DateTimeFormatHelpers.formatDateTime(resident.createdAt),
                          ),
                          _buildInformationItemWidget(
                            firstTitle: localization.email,
                            firstValue: resident.email,
                            secondTitle: localization.phone,
                            secondValue: resident.phoneNum ?? '',
                          ),
                          if (resident.status != .pending)
                            _buildInformationItemWidget(
                              firstTitle: localization.houseNumber,
                              firstValue: (houseNumber != null && houseNumber.isNotEmpty)
                                  ? '#$houseNumber'
                                  : localization.unknown,
                            ),
                          Padding(
                            padding: const .symmetric(vertical: 16.0),
                            child: Text(
                              "Vehicle Information",
                              style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.btnColor),
                            ),
                          ),
                          _buildInformationItemWidget(
                            firstTitle: localization.name,
                            firstValue: resident.vehicleInformation?.name ?? '',
                            secondTitle: localization.color,
                            secondValue: resident.vehicleInformation?.color ?? '',
                          ),
                          _buildInformationItemWidget(
                            firstTitle: localization.registrationNumber,
                            firstValue: resident.vehicleInformation?.registrationNumber ?? '',
                            secondTitle: localization.licensePlateNumber,
                            secondValue: resident.vehicleInformation?.licensePlateNumber ?? '',
                          ),
                          Column(
                            crossAxisAlignment: .start,
                            spacing: 10,
                            children: [
                              Text(
                                localization.emergencyContacts,
                                style: AppTextStyles.visitorDetailTitleTextStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: .w400,
                                ),
                              ),
                              if(resident.personalEmergencyPhone != null)
                              Text(
                                resident.personalEmergencyPhone!,
                                style: AppTextStyles.visitorDetailSubtitleTextStyle.copyWith(fontSize: 14),
                              )
                              else
                                Text(
                                  localization.noEmergencyContacts,
                                  style: AppTextStyles.visitorDetailSubtitleTextStyle.copyWith(fontSize: 14),
                                )

                            ],
                          ),
                          if (resident.status == .pending) ...[
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _houseNumberController,
                              hintText: localization.houseNumber,
                              fillColor: AppColors.fillColorGrey,
                              textInputType: .text,
                            ),
                            if (_houseNumberError != null)
                              Padding(
                                padding: const .only(top: 8),
                                child: Align(
                                  alignment: .centerLeft,
                                  child: Text(
                                    _houseNumberError!,
                                    style: AppTextStyles.tileSubtitleTextStyle.copyWith(color: Colors.red),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (resident.status == .pending)
                    Consumer<HomeProvider>(
                      builder: (ctx, provider, child) {
                        return SafeArea(
                          child: Padding(
                            padding: const .only(left: 18, right: 18, bottom: 24, top: 8),
                            child: Column(
                              spacing: 12,
                              children: [
                                SizedBox(
                                  width: .infinity,
                                  child: PrimaryBtn(
                                    onTap: () => _onApproveTap(provider, localization),
                                    btnText: localization.approve,
                                    isLoading: provider.updatingResidentStatus,
                                  ),
                                ),
                                SizedBox(
                                  width: .infinity,
                                  child: PrimaryBtn(
                                    onTap: () async {
                                      await provider.updateResident(resident.copyWith(status: .rejected));
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                    btnText: localization.reject,
                                    bgColor: Colors.red,
                                    isLoading: provider.updatingResidentStatus,
                                  ),
                                ),
                                TextButton(
                                  onPressed: provider.updatingResidentStatus
                                      ? null
                                      : () async {
                                          final confirmed = await CommonUI.confirmDelete(context);
                                          if (!confirmed || !context.mounted) return;
                                          await provider.deleteResident(resident);
                                          if (context.mounted) Navigator.pop(context);
                                        },
                                  child: Text(
                                    localization.delete,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onApproveTap(HomeProvider provider, AppLocalizations localization) async {
    final houseNumber = _houseNumberController.text.trim();
    if (houseNumber.isEmpty) {
      setState(() => _houseNumberError = localization.pleaseEnterHouseNumber);
      return;
    }
    setState(() => _houseNumberError = null);
    await provider.updateResident(
      widget.resident.copyWith(
        status: .approved,
        houseNumber: houseNumber,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Widget _buildInformationItemWidget({
    required String firstTitle,
    required String firstValue,
    String? secondTitle,
    String? secondValue,
  }) {
    return Column(
      children: [
        Row(
          spacing: 20,
          children: [
            Expanded(
              child: VisitorInfoItemWidget(title: firstTitle, subTitle: firstValue),
            ),
            if (secondTitle != null)
              Expanded(
                child: VisitorInfoItemWidget(title: secondTitle, subTitle: secondValue ?? ''),
              ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
