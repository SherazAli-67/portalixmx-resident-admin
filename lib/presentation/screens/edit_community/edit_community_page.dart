import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/core/res/app_constants.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:provider/provider.dart';
import '../../../core/res/app_textstyles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/edit_community_provider/edit_community_provider.dart';
import '../../widgets/app_textfield_widget.dart';
import '../../widgets/bg_gradient_screen.dart';

class EditCommunity extends StatefulWidget {
  const EditCommunity({super.key});

  @override
  State<EditCommunity> createState() => _EditCommunityState();
}

class _EditCommunityState extends State<EditCommunity> {

  final TextEditingController _nameController = .new();
  final TextEditingController _locationController = .new();
  EditUpdateCommunityProvider? _provider;
  String? _syncedSocietyId;

  void _syncControllersFromProvider() {
    final provider = _provider;
    if (provider == null || provider.loadingSociety || provider.society == null) {
      return;
    }
    if (_syncedSocietyId == provider.society!.id) {
      return;
    }
    _nameController.text = provider.society?.name ?? '';
    _locationController.text = provider.society?.location ?? '';
    _syncedSocietyId = provider.society!.id;
  }

  void _onProviderChanged() {
    _syncControllersFromProvider();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<EditUpdateCommunityProvider>(context, listen: false);
      _provider?.addListener(_onProviderChanged);
      _syncControllersFromProvider();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BgGradientScreen(child: Consumer<EditUpdateCommunityProvider>(
      builder: (ctx, provider, _){
        return Stack(
          children: [
            Column(
              spacing: 20,
              children: [
                Padding(padding: EdgeInsets.only(top: 65),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(color: Colors.white,),
                      Text(localizations.editCommunity, style: AppTextStyles.regularTextStyle,),
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
                    child: provider.loadingSociety ? LoadingWidget(color: AppColors.primaryColor,) : SingleChildScrollView(
                        padding: const .only(top: 36.0, left: 18, right: 18),
                        child: Column(
                          crossAxisAlignment: .start,
                          spacing: 15,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: .circular(10),
                                    child: CachedNetworkImage(imageUrl: provider.society?.imageUrl ?? AppConstants.dummyImageUrl)),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: IconButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.btnColor, shape: RoundedRectangleBorder(borderRadius: .circular(100))),
                                      padding: .zero,
                                      onPressed: (){}, icon: Icon(Icons.edit, color: Colors.white,)),
                                )
                              ],
                            ),
                            Column(
                              spacing: 10,
                              children: [
                                AppTextField(title: localizations.name, hintText: localizations.name, controller: _nameController,titleTextStyle: AppTextStyles.editProfileHeadingTextStyle, isDense: true, borderColor: AppColors.lightGreyBackgroundColor,),
                                AppTextField(title: localizations.address, hintText: localizations.address, controller: _locationController,titleTextStyle: AppTextStyles.editProfileHeadingTextStyle, isDense: true, borderColor: AppColors.lightGreyBackgroundColor,),
                              ],
                            ),
                            Container(
                              margin: .only(top: 65),
                              width: .infinity,
                              child: PrimaryBtn(onTap: ()=> onSubmitTap(context, localizations: localizations), btnText: localizations.update, isLoading: provider.updatingSociety,),
                            )
                          ],
                        )
                    ),
                  ),
                ),

              ],
            ),
            if(provider.updatingSociety)
              FullPageLoadingWidget(color: AppColors.primaryColor,)
          ],
        );
      },
    ),);
  }

  Future<void> onSubmitTap(BuildContext context,{required AppLocalizations localizations} )async{
    String name = _nameController.text.trim();
    String address = _locationController.text.trim();

    if(name.isEmpty || address.isEmpty){
      return;
    }

   String? error = await _provider?.updateSociety(name: name, address: address);
    if(error != null){
      CommonUI.showSnackBarMessage(context, isError: true, message: error);
    }else{
      CommonUI.showSnackBarMessage(context, isSuccess: true, message: localizations.societyInformationUpdated);
      Navigator.pop(context);
    }
  }
}










