import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String text;
  final ontap;
  final color;

  const CardWidget(this.text, this.ontap, this.color, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      margin: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Ink(
        height: 120,
        width: 120,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.amber,
        ),
        child: InkWell(
          onTap: () => ontap(),
          splashColor: Colors.black12,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
