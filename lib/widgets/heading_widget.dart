import 'package:bazario/utils/app_constant.dart';
import 'package:flutter/material.dart';

class HeadingWidget extends StatelessWidget {
  const HeadingWidget(
      {super.key,
      required this.headingTitle,
      required this.headingSubTitle,
      required this.buttonText,
      required this.onTab});

  final String headingTitle;
  final String headingSubTitle;
  final String buttonText;
  final VoidCallback onTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 5,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headingTitle,
                  style: TextStyle(
                      color: Colors.grey.shade800, fontWeight: FontWeight.bold),
                ),
                Text(
                  headingSubTitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            GestureDetector(
              onTap: onTab,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppConstant.appSceColor, width: 1.5)),
                child: Text(
                  buttonText,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppConstant.appSceColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
