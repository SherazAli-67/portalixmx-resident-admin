import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/l10n/app_localizations.dart';
import 'package:portalixmx_resident_admin/providers/community_directory_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/res/app_colors.dart';
import '../../../core/res/app_textstyles.dart';
import '../../widgets/bg_gradient_screen.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/resident_item_widget.dart';

class CommunityDirectoryPage extends StatelessWidget{
  const CommunityDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BgGradientScreen(child: ChangeNotifierProvider(
      create: (_)=> CommunityDirectoryProvider(),
      builder: (_, child) {
        return Consumer<CommunityDirectoryProvider>(
          builder: (_, provider, _) {
            return Column(
              spacing: 20,
              children: [
                Padding(padding: EdgeInsets.only(top: 65),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(color: Colors.white,),
                      Text(localizations.directory, style: AppTextStyles.regularTextStyle,),
                      const SizedBox(width: 20)
                    ],
                  ),
                ),

                Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: .zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: .only(topLeft: .circular(30), topRight: .circular(30))
                    ),
                    child: Padding(
                      padding: const .symmetric(horizontal: 16.0),
                      child: provider.loadingResidents ? LoadingWidget(color: AppColors.primaryColor,) : ListView.separated(itemBuilder: (ctx, index)=> ResidentItemWidget(resident: provider.residents[index], showStatus: true,), separatorBuilder: (_, index)=> const SizedBox(height: 10,), itemCount: provider.residents.length),
                    ),
                  ),
                ),

              ],
            );
          }
        );
      }
    ));
  }
}