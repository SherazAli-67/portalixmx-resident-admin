import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/app_dropdown_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/providers/datetime_format_helpers.dart';
import 'package:portalixmx_resident_admin/providers/payments_provider/payment_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';

class PaymentsMenu extends StatefulWidget{
  const PaymentsMenu({super.key});

  @override
  State<PaymentsMenu> createState() => _PaymentsMenuState();
}

class _PaymentsMenuState extends State<PaymentsMenu> {

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_)=> PaymentProvider(),
      builder: (ctx, child){
        return Consumer<PaymentProvider>(builder: (ctx, provider, child){
          return Stack(
            children: [
              Padding(
                padding: const .symmetric(horizontal: 15.0),
                child: Column(
                  spacing: 22,
                  children: [
                    Stack(
                      children: [
                        Align(
                            alignment: .center,
                            child: Padding(
                              padding: const .only(top: 35.0, bottom: 11),
                              child: Text(localization.paymentsAndBilling, textAlign: .center, style: AppTextStyles.headingTextStyle,),
                            )),
                        Align(
                          alignment: .topRight,
                          child: Padding(
                            padding: const .only(top: 30.0),
                            child: IconButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor),
                                onPressed: provider.onAddPaymentTap, icon: Icon(Icons.add, color: Colors.white,)),
                          ),
                        )
                      ],
                    ),
                    Row(
                      spacing: 20,
                      children: [
                        Expanded(child: AppDropdownWidget<String>(list: provider.getFilterList(localization), title: 'Date', value: provider.selectedFilter, onChanged: (val)=> provider.onChangeFilterTap(val), getTitle: (item) => item)),
                        Expanded(child: AppDropdownWidget<String>(list: provider.getStatusList(localization), title: 'Status', value: provider.selectedPaymentStatusFilter, onChanged: (val)=> provider.onChangeStatusFilterTap(val), getTitle: (item) => item)),

                      ],
                    ),
                  /*  Row(
                      spacing: 10,
                      children: [
                        _buildServiceTypeTab(serviceTypeTitle: localization.all, index: 0, provider: provider),
                        _buildServiceTypeTab(serviceTypeTitle: localization.week, index: 1, provider: provider),
                        _buildServiceTypeTab(serviceTypeTitle: localization.month, index: 2, provider: provider),
                      ],
                    ),*/
                    Expanded(
                        child: provider.loadingPayments
                            ? LoadingWidget()
                            : provider.payments.isEmpty
                            ? Center(child: Text("No payment requests found", style: AppTextStyles.regularTextStyle,),)
                            : ListView.builder(
                            itemCount: provider.payments.length,
                            itemBuilder: (ctx, index){
                              PaymentModel payment = provider.payments[index];
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
                                        child: Center(child: Text('${payment.paymentForTitle[0]}${payment.paymentForTitle[0]}', style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),),
                                      ),
                                      Expanded(
                                        child: Column(
                                          spacing: 2,
                                          crossAxisAlignment: .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: .spaceBetween,
                                              children: [
                                                Text(payment.paymentForTitle, style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),
                                                Text("\$${payment.amount}", style: TextStyle(fontSize: 12, fontWeight: .w700, color: AppColors.btnColor),)
                                              ],
                                            ),
                                            Text(DateTimeFormatHelpers.formatDateTime(payment.dateTime), style: TextStyle(fontSize: 10, fontWeight: .w500, color: AppColors.serviceSubTitleGreyColor),),
                                            const SizedBox(height: 3,),
                                            Text(payment.description, style: AppTextStyles.emergencyContactTitleTextStyle,)
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              );
                            })
                    )
                  ],
                ),
              ),
              if(provider.addingPayment)
                FullPageLoadingWidget()
            ],
          );
        });
      },
    );
  }
}