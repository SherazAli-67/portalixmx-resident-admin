import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalixmx_resident_admin/core/common_ui.dart';
import 'package:portalixmx_resident_admin/core/res/app_colors.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/full_page_loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/loading_widget.dart';
import 'package:portalixmx_resident_admin/presentation/widgets/primary_btn.dart';
import 'package:portalixmx_resident_admin/router/app_router.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
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
    return BgGradientScreen(
      child: Consumer<EditUpdateCommunityProvider>(
        builder: (ctx, provider, _) {
          return Stack(
            children: [
              Column(
                spacing: 20,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 65),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(color: Colors.white),
                        Text(
                          localizations.editCommunity,
                          style: AppTextStyles.regularTextStyle,
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: provider.loadingSociety
                          ? const LoadingWidget(color: AppColors.primaryColor)
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                top: 36.0,
                                left: 18,
                                right: 18,
                                bottom: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 15,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: provider.pickedImage != null
                                            ? Image.file(File(provider.pickedImage!.path))
                                            : (provider.society?.imageUrl != null &&
                                                    provider.society!.imageUrl.isNotEmpty)
                                                ? CachedNetworkImage(
                                                    imageUrl: provider.society!.imageUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: 180,
                                                  )
                                                : Container(
                                                    width: double.infinity,
                                                    height: 180,
                                                    color: Colors.grey.shade200,
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      Icons.image_outlined,
                                                      size: 48,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: IconButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.btnColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100),),
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: ()=> provider.onEditProfilePictureTap(),
                                          icon: const Icon(Icons.edit, color: Colors.white,),),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    spacing: 10,
                                    children: [
                                      AppTextField(
                                        title: localizations.name,
                                        hintText: localizations.name,
                                        controller: _nameController,
                                        titleTextStyle: AppTextStyles.editProfileHeadingTextStyle,
                                        isDense: true,
                                        borderColor: AppColors.lightGreyBackgroundColor,),
                                      AppTextField(
                                        title: localizations.address,
                                        hintText: localizations.address,
                                        controller: _locationController,
                                        titleTextStyle: AppTextStyles.editProfileHeadingTextStyle,
                                        isDense: true,
                                        borderColor: AppColors.lightGreyBackgroundColor,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 65),
                                    width: double.infinity,
                                    child: PrimaryBtn(
                                      onTap: () => onSubmitTap(context, localizations: localizations,),
                                      btnText: localizations.update,
                                      isLoading: provider.updatingSociety,
                                    ),
                                  ),
                                  if (provider.isOwner)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primaryColor,
                                          side: const BorderSide(
                                            color: AppColors.primaryColor,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        onPressed: () => context.push(
                                          NamedRoutes
                                              .transferOwnership.routeName,
                                        ),
                                        child: Text(
                                          localizations.transferOwnership,
                                          style: AppTextStyles.btnTextStyle
                                              .copyWith(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              if (provider.updatingSociety)
                const FullPageLoadingWidget(color: AppColors.primaryColor),
            ],
          );
        },
      ),
    );
  }

  Future<void> onSubmitTap(
    BuildContext context, {
    required AppLocalizations localizations,
  }) async {
    String name = _nameController.text.trim();
    String address = _locationController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      return;
    }

    String? error = await _provider?.updateSociety(name: name, address: address);
    if (!context.mounted) return;
    if (error != null) {
      CommonUI.showSnackBarMessage(context, isError: true, message: error);
    } else {
      CommonUI.showSnackBarMessage(
        context,
        isSuccess: true,
        message: localizations.societyInformationUpdated,
      );
      Navigator.pop(context);
    }
  }
}
