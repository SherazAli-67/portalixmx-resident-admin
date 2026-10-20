import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/providers/datetime_format_helpers.dart';
import 'package:portalixmx_resident_admin/providers/home_provider.dart';
import 'package:portalixmx_resident_admin/services/user_service/user_service.dart';
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
  late Future<List<String>> _emergencyContactLabels;

  @override
  void initState() {
    super.initState();
    _emergencyContactLabels = _loadEmergencyContacts();
  }

  Future<List<String>> _loadEmergencyContacts() async {
    final ids = widget.resident.emergencyContacts;
    if (ids.isEmpty) return [];
    final labels = <String>[];
    for (final id in ids) {
      final user = await UserService.instance.getUserByID(userID: id);
      if (user == null) {
        labels.add(id);
        continue;
      }
      final phone = user.phoneNum?.trim();
      labels.add((phone != null && phone.isNotEmpty) ? '${user.userName} ($phone)' : user.userName);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final resident = widget.resident;
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
                Text(resident.userName, style: AppTextStyles.regularTextStyle),
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
              child: Padding(
                padding: const .only(top: 36.0, left: 18, right: 18),
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
                        FutureBuilder<List<String>>(
                          future: _emergencyContactLabels,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == .waiting) {
                              return const Padding(
                                padding: .symmetric(vertical: 8),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            final contacts = snapshot.data ?? [];
                            if (contacts.isEmpty) {
                              return Text(
                                'No emergency contacts',
                                style: AppTextStyles.visitorDetailSubtitleTextStyle.copyWith(fontSize: 14),
                              );
                            }
                            return Column(
                              spacing: 5,
                              crossAxisAlignment: .start,
                              children: contacts
                                  .map(
                                    (label) => Text(
                                      label,
                                      style: AppTextStyles.visitorDetailSubtitleTextStyle.copyWith(fontSize: 14),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (resident.status == .pending)
                      Consumer<HomeProvider>(
                        builder: (ctx, provider, child) {
                          return SafeArea(
                            child: Padding(
                              padding: const .only(bottom: 24),
                              child: Column(
                                spacing: 12,
                                children: [
                                  SizedBox(
                                    width: .infinity,
                                    child: PrimaryBtn(
                                      onTap: () async {
                                        await provider.updateResident(resident.copyWith(status: .approved));
                                        if (context.mounted) Navigator.pop(context);
                                      },
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
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text(localization.delete),
                                                content: const Text('Delete this resident permanently?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(ctx, false),
                                                    child: Text(localization.cancel),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    child: Text(localization.delete),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed != true) return;
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
          ),
        ],
      ),
    );
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
