import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingSpinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitSpinningLines(
          size: 40,
          color: Theme.of(context).colorScheme.secondary,
          itemCount: 3,
          lineWidth: 3,
          duration: Duration(milliseconds: 2000),
        )
      ],
    ),
  );
}
