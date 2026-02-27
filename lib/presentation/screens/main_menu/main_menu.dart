import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/res/app_icons.dart';
import '../../../l10n/app_localizations.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
class MainMenuPage extends StatelessWidget{
  const MainMenuPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: Scaffold(
        bottomNavigationBar: SizedBox(
          height: 110,
          child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: (index)=> navigationShell.goBranch(index),
              backgroundColor: AppColors.primaryColor,
              showSelectedLabels: false,
              unselectedItemColor: Colors.white,
              currentIndex: navigationShell.currentIndex,
              selectedLabelStyle: TextStyle(fontSize: 11),
              unselectedLabelStyle: TextStyle(fontSize: 12, color: Colors.white),
              items: [
                _buildBottomNavigationItemWidget(icon: AppIcons.icHomeMenu, label: AppLocalizations.of(context)!.home, isSelected: navigationShell.currentIndex == 0),
                _buildBottomNavigationItemWidget(icon: AppIcons.icPaymentsMenu, label: AppLocalizations.of(context)!.payments, isSelected: navigationShell.currentIndex == 1),
                _buildBottomNavigationItemWidget(icon: AppIcons.icMaintenance, label: AppLocalizations.of(context)!.maintenance, isSelected: navigationShell.currentIndex == 2),
                _buildBottomNavigationItemWidget(icon: AppIcons.icAccess, label: AppLocalizations.of(context)!.access, isSelected: navigationShell.currentIndex == 3),
                _buildBottomNavigationItemWidget(icon: AppIcons.icMenu, label: AppLocalizations.of(context)!.menu, isSelected: navigationShell.currentIndex == 4),

              ]),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height*0.7,
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.btnColor,
                          AppColors.btnColor.withValues(alpha: 0.0)
                        ])
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 50,
              child: Image.asset(AppIcons.icScreenBg, height: 150,),
            ),
            SafeArea(child: navigationShell),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationItemWidget({required String icon, required String label, required bool isSelected}) =>
      BottomNavigationBarItem(
        icon: isSelected ? Container(
          padding: const EdgeInsets.all(12.0),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              color: AppColors.btnColor,
              shape: BoxShape.circle
          ),
          child: SvgPicture.asset(icon, height: 25, ),
        ) : SvgPicture.asset(icon, height: 25, ), label: isSelected ? '': label,);



/* Widget _buildResidentMenuItem(int currentIndex) {
    switch(currentIndex){
      case 0:
        return HomePage();

      case 1:
        return MaintenanceMenu();

      case 2:
        return AccessMenu();

      case 3:
        return ProfileMenu();

      default:
        return HomePage();
    }
  }*/
}