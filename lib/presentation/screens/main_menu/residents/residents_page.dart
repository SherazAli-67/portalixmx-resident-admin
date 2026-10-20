import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/app_dropdown_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/bg_gradient_screen.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/resident_item_widget.dart';
import 'package:portalixmx_resident_admin/providers/residents_provider/residents_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/res/app_textstyles.dart';

class ResidentsPage extends StatelessWidget{
  const ResidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => ResidentsProvider(),
      builder: (ctx, child){
        return BgGradientScreen(child: SafeArea(
          child: Consumer<ResidentsProvider>(
            builder: (_, provider, _){
              final filteredResidents = provider.getFilteredResidents(localization);
              return Padding(
                padding: .symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  spacing: 16,
                  children: [

                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        BackButton(color: Colors.white,),
                        provider.loadingSociety ? LoadingWidget() : Text(provider.society?.name ?? '', style: AppTextStyles.regularTextStyle),
                        const SizedBox(width: 40,),
                      ],
                    ),
                    Expanded(
                      child: Padding(padding: .symmetric(horizontal: 10), child: Column(
                        spacing: 24,
                        children: [
                          Row(
                            spacing: 20,
                            children: [
                              Expanded(child: AppDropdownWidget<String>(list: provider.getFilterList(localization), title: 'Date', value: provider.selectedFilter, onChanged: (val)=> provider.onChangeFilterTap(val), getTitle: (item) => item)),
                              Expanded(child: AppDropdownWidget<String>(list: provider.getStatusList(localization), title: 'Status', value: provider.selectedPaymentStatusFilter, onChanged: (val)=> provider.onChangeStatusFilterTap(val), getTitle: (item) => item)),
                            ],
                          ),
                          Expanded(
                            child: provider.loadingResident
                                ? LoadingWidget()
                                : filteredResidents.isEmpty
                                ? Center(
                              child: Text(
                                localization.emptyResidentsMsg,
                                style: AppTextStyles.regularTextStyle,
                              ),
                            )
                                : ListView.separated(
                              itemBuilder: (ctx, index){
                                return ResidentItemWidget(resident: filteredResidents[index]);
                              },
                              separatorBuilder: (ctx, index) => const SizedBox(height: 10,),
                              itemCount: filteredResidents.length,
                            ),
                          )
                        ],
                      ),),
                    )
                  ],
                ),
              );
            },
          ),
        ));
      },
    );
  }
}