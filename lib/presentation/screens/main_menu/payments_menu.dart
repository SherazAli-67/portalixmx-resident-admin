import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/date_range_filter_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/providers/datetime_format_helpers.dart';
import 'package:portalixmx_resident_admin/providers/payments_provider/payment_provider.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';

class PaymentsMenu extends StatelessWidget{
  const PaymentsMenu({super.key});

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
                                onPressed: () => _onAddPaymentTap(ctx, provider: provider, localization: localization), icon: Icon(Icons.add, color: Colors.white,)),
                          ),
                        )
                      ],
                    ),
                    DateRangeFilterWidget(
                      dateFrom: provider.dateFrom,
                      dateTo: provider.dateTo,
                      onDateFromChanged: provider.onDateFromChanged,
                      onDateToChanged: provider.onDateToChanged,
                    ),
                    // AppDropdownWidget<String>(list: provider.getStatusList(localization), title: 'Status', value: provider.selectedPaymentStatusFilter, onChanged: (val)=> provider.onChangeStatusFilterTap(val), getTitle: (item) => item),
                    Expanded(
                        child: provider.loadingPayments
                            ? LoadingWidget()
                            : RefreshIndicator(
                                onRefresh: () => provider.refreshPayments(),
                                child: ((){
                              final list = provider.getFilteredPayments(localization);
                              return list.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height * 0.35,
                                    child: Center(child: Text("No payment requests found", style: AppTextStyles.regularTextStyle,),),
                                  ),
                                ],
                              )
                            : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (ctx, index){
                              PaymentModel payment = list[index];
                              final counts = provider.getCountsFor(payment.paymentID);
                              return GestureDetector(
                                onTap: ()=> _onPaymentItemTap(context, payment: payment, provider: provider),
                                child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                    child: Row(
                                      spacing: 17,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                          child: Center(child: Text('${payment.paymentForTitle[0]}${payment.paymentForTitle[0]}', style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),),
                                        ),
                                        Expanded(
                                          child: Column(
                                            spacing: 2,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(payment.paymentForTitle, style: AppTextStyles.tileTitleTextStyle.copyWith(color: AppColors.primaryColor),),
                                              Text(DateTimeFormatHelpers.formatDateTime(payment.dateTime), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.serviceSubTitleGreyColor),),
                                              const SizedBox(height: 3,),
                                              Row(
                                                mainAxisAlignment: .spaceBetween,
                                                children: [
                                                  Text(payment.description, style: AppTextStyles.emergencyContactTitleTextStyle,),
                                                  Text("\$${payment.amount}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.btnColor),)
                                                ],
                                              ),
                                              const SizedBox(height: 4,),
                                              Text(
                                                '${counts.pending} ${localization.pending} · ${counts.submitted} ${localization.submitted} · ${counts.received} ${localization.received}',
                                                style: TextStyle(fontSize: 10, fontWeight: .w500, color: AppColors.serviceSubTitleGreyColor),
                                              )
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _onDeletePaymentTap(ctx, payment: payment, provider: provider, localization: localization),
                                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        ),
                                      ],
                                    )
                                ),
                              );
                            },
                            );
                            })(),
                              ),
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
  
  void _onPaymentItemTap(BuildContext context, {required PaymentModel payment, required PaymentProvider provider})async{
   await context.push(NamedRoutes.paymentDetail.routeName, extra: payment);
   await provider.refreshPayments();
  }

  Future<void> _onAddPaymentTap(BuildContext context, {required PaymentProvider provider, required AppLocalizations localization}) async {
    final result = await provider.onAddPaymentTap();
    if (!context.mounted || result == null) return;
    if (result) {
      CommonUI.showSnackBarMessage(context, message: localization.paymentCreated, isSuccess: true);
    } else {
      CommonUI.showSnackBarMessage(context, message: localization.failedToCreatePayment, isError: true);
    }
  }

  Future<void> _onDeletePaymentTap(BuildContext context, {required PaymentModel payment, required PaymentProvider provider, required AppLocalizations localization}) async {
    final error = await provider.deletePayment(payment);
    if (!context.mounted) return;
    if (error != null) {
      CommonUI.showSnackBarMessage(context, message: localization.failedToDeletePayment, isError: true);
    } else {
      CommonUI.showSnackBarMessage(context, message: localization.paymentDeleted(payment.paymentForTitle), isSuccess: true);
    }
  }
}