import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/helpers/image_url_helper.dart';
import '../../../../core/models/complaints_model.dart';
import '../../../../core/res/app_textstyles.dart';
import '../../../../providers/datetime_format_helpers.dart';
import '../../../widgets/bg_gradient_screen.dart';
import '../../../widgets/vistor_info_item_widget.dart';

class ComplaintSummaryPage extends StatelessWidget{
  const ComplaintSummaryPage({super.key, required this.complaint});
  final ComplaintModel complaint;
  @override
  Widget build(BuildContext context) {
    return BgGradientScreen(child: Column(
      spacing: 20,
      children: [
        Padding(padding: EdgeInsets.only(top: 65),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(color: Colors.white,),
              Text(complaint.complaint, style: AppTextStyles.regularTextStyle,),
              const SizedBox(width: 20)
            ],
          ),
        ),

        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 36.0, left: 18, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 20,
                    children: [
                      Expanded(
                        child: VisitorInfoItemWidget(
                          title: 'Date', subTitle: DateTimeFormatHelpers.formatDateTime(complaint.createdAt), ),
                      ),
                      Expanded(
                          child: VisitorInfoItemWidget(
                            title: 'Status', subTitle: complaint.status.name.toUpperCase(),)
                      ),
                    ],
                  ),
                  Divider(),
                  VisitorInfoItemWidget(title: 'Complaint', subTitle: complaint.complaint, showDivider: true),
                  Text("Photos", style: AppTextStyles.visitorDetailTitleTextStyle,),
                  Expanded(child: GridView.builder(
                      itemCount: complaint.images.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,   mainAxisSpacing: 10, crossAxisSpacing: 10), itemBuilder: (ctx, index){
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(imageUrl: ImageUrlHelper.getImageUrl(complaint.images[index]), height: 75, fit: BoxFit.cover,),
                    );
                  }))
                ],
              )
            ),
          ),
        )
      ],
    ),);
  }

}