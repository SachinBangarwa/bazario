import 'package:bazario/controllers/banners_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final CarouselSliderController carouselSliderController =
      CarouselSliderController();
  final BannersController bannersController = Get.put(BannersController());

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        CarouselSlider(
          items: bannersController.bannerUrls
              .map((images) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: images,
                      placeholder: (context, url) => const ColoredBox(
                        color: Colors.white,
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: Get.width - 10,
                    ),
                  ))
              .toList(),
          options: CarouselOptions(
              scrollDirection: Axis.horizontal,
              autoPlay: true,
              aspectRatio: 2.5,
              viewportFraction: 1),
        ));
  }
}
