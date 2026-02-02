import 'package:doova/r.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, required this.size});
  final Size size;
  @override
  Widget build(BuildContext context) {
    return SpinKitWanderingCubes(
      size: size.height * 0.05,
      color: Color(0xff6F24E9),
    );
  }
}

Widget buildCustomSpinner(BuildContext context, Size size) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: size.height * 0.06,
        width: size.width * 0.06,
        child:
            Lottie.asset(LottieManager.spinner), // Replace with your file path
      ),
    ),
  );
}
