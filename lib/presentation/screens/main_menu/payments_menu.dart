import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/filter_tab_widget.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';

class PaymentsMenu extends StatefulWidget{
  const PaymentsMenu({super.key});

  @override
  State<PaymentsMenu> createState() => _PaymentsMenuState();
}

class _PaymentsMenuState extends State<PaymentsMenu> {
  int _selectedServiceTypeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Padding(
      padding: const .symmetric(horizontal: 15.0),
      child: Column(
        spacing: 22,
        children: [
          Align(
              alignment: .center,
              child: Padding(
                padding: const .only(top: 35.0, bottom: 11),
                child: Text(localization.paymentsAndBilling, textAlign: .center, style: AppTextStyles.headingTextStyle,),
              )),
          Row(
            spacing: 10,
            children: [
              _buildServiceTypeTab(serviceTypeTitle: localization.currentService, index: 0),
              _buildServiceTypeTab(serviceTypeTitle: localization.otherServices, index: 1),
            ],
          ),
          Expanded(
            child: Center(child: Text("No payment requests found", style: AppTextStyles.regularTextStyle,),)
          )
        ],
      ),
    );
  }

  Widget _buildServiceTypeTab({required String serviceTypeTitle, required int index}) {
    bool isSelected = index == _selectedServiceTypeIndex;
    return Expanded(
        child: FilterTabWidget(isSelected: isSelected,
        onTap: () => setState(() => _selectedServiceTypeIndex = index),
        title: serviceTypeTitle));
  }
}