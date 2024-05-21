import 'package:flutter/material.dart';

Color activeColor = const Color(0xFFD2232A);

class InfoCard extends StatefulWidget {
  const InfoCard(
      {Key? key,
        required this.title,
        required this.value,
        this.isActive = false,
        required this.onTap,
        this.topColor})
      : super(key: key);

  final String title;
  final num value;
  final Color? topColor;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          height: 150, // Height of the Cards
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white, // Box Color
            boxShadow: [
              BoxShadow( // Shadow of the Cards
                  offset: const Offset(0, 6),
                  color: const Color(0xFFD2232A).withOpacity(.1),
                  blurRadius: 12)
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Container(
                        // Bar above Cards
                        color: widget.topColor ?? activeColor,
                        // If topColor is not given,
                        // bar Color will be ODTU Color
                        height: 5,
                      )
                  )
                ],
              ),
              Expanded(child: Container()),
              RichText(
                // Settings of the Card Information
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan( // Settings of Title of the Card
                        text: "${widget.title}\n",
                        style: TextStyle(
                            fontSize: 20,
                            color: widget.isActive ? activeColor : const Color(
                                0xFF0C0707))),
                    TextSpan( // Settings of Value of the Card
                        text: "${widget.value}",
                        style: TextStyle(
                            fontSize: 40,
                            color: widget.isActive ? activeColor : const Color(
                                0xFF131313))),
                  ])),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}