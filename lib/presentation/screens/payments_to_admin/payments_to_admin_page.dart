import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/models/payment_model.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/app_dropdown_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/bg_gradient_screen.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/providers/admin_payments_provider/payments_to_admin_provider.dart';
import 'package:portalixmx_resident_admin/providers/datetime_format_helpers.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';

class PaymentsToAdminPage extends StatefulWidget{
  const PaymentsToAdminPage({super.key});

  @override
  State<PaymentsToAdminPage> createState() => _PaymentsToAdminPageState();
}

class _PaymentsToAdminPageState extends State<PaymentsToAdminPage> {

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BgGradientScreen(
      child: SafeArea(
        child: ChangeNotifierProvider(
          create: (_)=> PaymentsToAdminProvider(),
          builder: (ctx, child){
            return Consumer<PaymentsToAdminProvider>(builder: (ctx, provider, child){
              return Stack(
                children: [
                  Padding(
                    padding: const .symmetric(horizontal: 15.0),
                    child: Column(
                      spacing: 22,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const BackButton(color: Colors.white),
                            Text(AppLocalizations.of(context)!.paymentToAdmin, style: AppTextStyles.regularTextStyle),
                            const SizedBox(width: 40),
                          ],
                        ),

                        Row(
                          spacing: 20,
                          children: [
                            Expanded(child: AppDropdownWidget<String>(list: provider.getFilterList(localization), title: 'Date', value: provider.selectedFilter, onChanged: (val)=> provider.onChangeFilterTap(val), getTitle: (item) => item)),
                            Expanded(child: AppDropdownWidget<String>(list: provider.getStatusList(localization), title: 'Status', value: provider.selectedPaymentStatusFilter, onChanged: (val)=> provider.onChangeStatusFilterTap(val), getTitle: (item) => item)),
                          ],
                        ),
                        Expanded(
                            child: provider.loadingPayments
                                ? LoadingWidget()
                                : ((){
                              final list = provider.getFilteredPayments(localization);
                              return list.isEmpty
                                  ? Center(child: Text("No payment requests found", style: AppTextStyles.regularTextStyle,),)
                                  : ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (ctx, index){
                                    PaymentModel payment = list[index];
                                    return GestureDetector(
                                      onTap: ()=> _onItemTap(payment, context, provider),
                                      child: Container(
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
                                      ),
                                    );
                                  });
                            })()
                        )
                      ],
                    ),
                  ),
                  if(provider.updatingPayment)
                    FullPageLoadingWidget()
                ],
              );
            });
          },
        ),
      ),
    );
  }

  void _onItemTap(PaymentModel payment, BuildContext context, PaymentsToAdminProvider provider) async {
    final localization = AppLocalizations.of(context)!;
    final result = await context.push(NamedRoutes.paymentsToAdminDetail.routeName, extra: payment);
    await provider.refresh();
    if (result != null && context.mounted) {
      CommonUI.showSnackBarMessage(
        context,
        message: localization.paymentToAdminSubmitted,
        isSuccess: true,
      );
    }
  }
}