import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/user_model.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/core/res/app_textstyles.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';

class SelectEmergencyContactsBottomSheet extends StatefulWidget {
  const SelectEmergencyContactsBottomSheet({
    super.key,
    required this.residents,
    required this.initiallySelectedIds,
  });

  final List<UserModel> residents;
  final List<String> initiallySelectedIds;

  @override
  State<SelectEmergencyContactsBottomSheet> createState() =>
      _SelectEmergencyContactsBottomSheetState();
}

class _SelectEmergencyContactsBottomSheetState
    extends State<SelectEmergencyContactsBottomSheet> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initiallySelectedIds};
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Padding(
      padding: const .symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        spacing: 15,
        children: [
          Text(
            localization.selectEmergencyContacts,
            style: AppTextStyles.bottomSheetHeadingTextStyle,
          ),
          if (widget.residents.isEmpty)
            Padding(
              padding: const .symmetric(vertical: 24),
              child: Text(
                localization.emptyResidentsMsg,
                textAlign: .center,
                style: AppTextStyles.tileTitleTextStyle,
              ),
            )
          else
            ...widget.residents.map((resident) {
              final selected = _selectedIds.contains(resident.userID);
              return Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: .circular(15),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primaryColor
                        : AppColors.borderColor2,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () => _toggle(resident.userID),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.btnColor,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    resident.userName,
                    style: AppTextStyles.tileTitleTextStyle,
                  ),
                  subtitle: Text(
                    resident.phoneNum ?? resident.email,
                    style: AppTextStyles.tileSubtitleTextStyle,
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                      : const Icon(Icons.circle_outlined, color: AppColors.greyColor),
                ),
              );
            }),
          Padding(
            padding: const .symmetric(vertical: 18.0),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: PrimaryBtn(
                onTap: () => Navigator.pop(context, _selectedIds.toList()),
                btnText: localization.save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(String userID) {
    setState(() {
      _selectedIds.contains(userID)
          ? _selectedIds.remove(userID)
          : _selectedIds.add(userID);
    });
  }
}
