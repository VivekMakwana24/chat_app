import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_structure/generated/assets.dart';
import 'package:flutter_demo_structure/values/colors.dart';
import 'package:flutter_demo_structure/values/extensions/export.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageViewerWidget extends StatelessWidget {
  final String imageUrl;

  const ImageViewerWidget({
    required this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          // Navigator.pop(context);
        }
      },
      child: Container(
        height: context.height,
        width: context.width,
        color: AppColor.blackColor.withOpacity(0.5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              maxScale: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: imageUrl ?? '',
                        fit: BoxFit.contain,
                        // height: height.toDouble(),
                        errorWidget: (context, url, error) {
                          debugPrint('ERROR LOADING URL ==>');
                          return CachedNetworkImage(
                            imageUrl: url ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (context, url, error) {
                              debugPrint('error${error}');
                              debugPrint('url${url}');
                              return const CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                              ).wrapPadding(padding: const EdgeInsets.all(30)).wrapCenter();
                            },
                          );
                        },
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: const CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                            ).wrapPadding(padding: const EdgeInsets.all(5)),
                          ),
                        ),
                        // height: 140,
                        color: AppColor.transparent,
                        colorBlendMode: BlendMode.colorBurn,
                      )
                    : const SizedBox(),
              ),
            ).wrapCenter(),
            Positioned(
              top: 20,
              right: 20,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  Assets.svgsIcClose,
                  height: 40,
                  width: 40,
                ),
              ).addGestureTap(() => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}
