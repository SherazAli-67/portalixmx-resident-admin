import 'package:flutter/material.dart';
import '../../../core/res/app_colors.dart';
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
            
           /* ListView.builder(
                itemCount: 5,
                itemBuilder: (ctx, index){
                  return Container(
                    margin: .only(bottom: 10),
                    padding: .symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: .circular(15)),
                    child: Row(
                      spacing: 17,
                      crossAxisAlignment: .start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                          child: Center(child: Text("SN", style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),),
                        ),
                        Expanded(
                          child: Column(
                            spacing: 2,
                            crossAxisAlignment: .start,
                            children: [
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text(localization.serviceName, style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),
                                  Text("\$500", style: TextStyle(fontSize: 12, fontWeight: .w700, color: AppColors.btnColor),)
                                ],
                              ),
                              Text("Sep 20, 2024", style: TextStyle(fontSize: 10, fontWeight: .w500, color: AppColors.serviceSubTitleGreyColor),),
                              const SizedBox(height: 3,),
                              _buildServiceInfoItemWidget(serviceText: localization.maintenance, serviceCharges: 300),
                              _buildServiceInfoItemWidget(serviceText: localization.cleaningOfCommonAreas, serviceCharges: 200),
                              _buildServiceInfoItemWidget(serviceText: localization.garbageCollection, serviceCharges: 100),
                            ],
                          ),
                        )
                      ],
                    )
                  );
                }),*/
          )
        ],
      ),
    );
  }

  Widget _buildServiceTypeTab({required String serviceTypeTitle, required int index}) {
    bool isSelected = index == _selectedServiceTypeIndex;
    return Expanded(child: ElevatedButton(
        style: isSelected ? ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor): null,
        onPressed: ()=> setState(()=>  _selectedServiceTypeIndex = index),
        child: Text(serviceTypeTitle, style: AppTextStyles.tabsTextStyle.copyWith(color: isSelected ? Colors.white : AppColors.primaryColor),)));
  }
}