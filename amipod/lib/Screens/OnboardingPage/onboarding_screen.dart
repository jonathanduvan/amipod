import 'dart:convert' show base64Decode, base64Url, base64UrlEncode;
import 'dart:io';

import 'package:dipity/Screens/Home/home_screen.dart';

import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';

// import 'package:geocode/geocode.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'assets/images/andy.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 200]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.white);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: backgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: backgroundColor,
      allowImplicitScrolling: true,
      autoScrollDuration: 1750,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('dipity_diego.png', 70),
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: const Text(
            "I'm Ready!",
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Welcome to Dipity",
          body:
              "Intentionally invest in your friendships and other relationships, without spending more time on your phone.",
          image: _buildImage('dipity-1024.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Focus on the Real Ones",
          body:
              "We only use your phone's contacts list to help you connect to your friends, family, and colleagues. If both parties have each other's numbers saved and use Dipity, they can connect!",
          image: _buildImage('dipity-1024.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Make Maps Cool Again",
          body:
              "Share your approximate location with other Dipity users in your contacts to get alerted if someone you know is in your area, whether you're traveling or in case an old friend is passing through town.",
          image: _buildImage('dipity-1024.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
            title: "Pod Up",
            body:
                "Organize your connections and contacts into groups called Pods. You can easily view connections in a pod on the Dipity map too!",
            image: _buildImage('dipity-1024.png'),
            decoration: pageDecoration),
        PageViewModel(
          title: "Take a Break",
          body:
              "Need more alone time? Turn on Uncharted Mode to pause sending and receiving location updates from your connections.",
          image: _buildImage('dipity-1024.png'),
          decoration: pageDecoration,
        ),
        // PageViewModel(
        //   title: "Full Screen Page",
        //   body:
        //       "Pages can be full screen as well.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.",
        //   image: _buildFullscreenImage(),
        //   decoration: pageDecoration.copyWith(
        //     contentMargin: const EdgeInsets.symmetric(horizontal: 16),
        //     fullScreen: true,
        //     bodyFlex: 2,
        //     imageFlex: 3,
        //     safeArea: 100,
        //   ),
        // ),
        // PageViewModel(
        //   title: "Another title page",
        //   body: "Another beautiful body text for this example onboarding",
        //   image: _buildImage('dipity_diego.png'),
        //   footer: ElevatedButton(
        //     onPressed: () {
        //       introKey.currentState?.animateScroll(0);
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.lightBlue,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //       ),
        //     ),
        //     child: const Text(
        //       'FooButton',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //   ),
        //   decoration: pageDecoration.copyWith(
        //     bodyFlex: 6,
        //     imageFlex: 6,
        //     safeArea: 80,
        //   ),
        // ),
        //   PageViewModel(
        //     title: "Title of last page - reversed",
        //     bodyWidget: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: const [
        //         Text("Click on ", style: bodyStyle),
        //         Icon(Icons.edit),
        //         Text(" to edit a post", style: bodyStyle),
        //       ],
        //     ),
        //     decoration: pageDecoration.copyWith(
        //       bodyFlex: 2,
        //       imageFlex: 4,
        //       bodyAlignment: Alignment.bottomCenter,
        //       imageAlignment: Alignment.topCenter,
        //     ),
        //     image: _buildImage('dipity_diego.png'),
        //     reverse: true,
        //   ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(
        Icons.arrow_back,
        color: primaryColor,
      ),
      skip: const Text('Skip',
          style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor)),
      next: const Icon(
        Icons.arrow_forward,
        color: primaryColor,
      ),
      done: const Text('Done',
          style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
