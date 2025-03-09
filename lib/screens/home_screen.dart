import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:random_quote_generator/components/constant.dart';
import 'package:random_quote_generator/components/quotes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>>? imageList;
  int imageNumber = 0;
  final CarouselController _carouselController = CarouselController();
  final Random _random = Random();

  final List<String> _defaultBlurHashes = [
    'L9DI.D%NxbaJ~VIUj[j@ROWVaef6',
    'L6O{Lqs:_3t7t7WBofj[.8WVRjWB',
    'LEC+~}%MayRj~qxuWBj[^+j[f6ay',
    'LLD9r7Rj~qM{ofj[IUay~qxut7WB',
    'L7F~RMs:rXRj~qoffQj[bHfQWAay',
  ];

  @override
  void initState() {
    super.initState();
    _loadImagesFromPicsum();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: imageList != null
          ? Stack(
        children: [
          // Background Image with BlurHash
          SizedBox(
            width: width,
            height: height,
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: BlurHash(
                key: ValueKey(imageList![imageNumber]['blur_hash']),
                hash: imageList![imageNumber]['blur_hash'],
                duration: const Duration(milliseconds: 500),
                image: imageList![imageNumber]['url'],
                curve: Curves.easeInOut,
                imageFit: BoxFit.cover,
              ),
            ),
          ),

          // Dark Overlay for better readability
          Container(
            width: width,
            height: height,
            color: Colors.black.withOpacity(0.6),
          ),

          // Quote Carousel
          SizedBox(
            width: width,
            height: height,
            child: SafeArea(
              child: CarouselSlider.builder(
                carouselController: CarouselSliderController(),
                itemCount: quotesList.length,
                itemBuilder: (context, index, realIndex) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Quote Text with Background
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.all(20.0),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            quotesList[index][kQuote],
                            style: kQuoteTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Author Name
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Text(
                            '- ${quotesList[index][kAuthor]} -',
                            style: kAuthorTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Share Button
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white, size: 30),
                          onPressed: () {
                            String quote = quotesList[index][kQuote];
                            String author = quotesList[index][kAuthor];
                            Share.share('"$quote" - $author');
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  scrollDirection: Axis.vertical,
                  pageSnapping: true,
                  initialPage: 0,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  height: height,
                  onPageChanged: (index, reason) {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      imageNumber = index;
                    });
                  },
                ),
              ),
            ),
          ),

          // Image Credit Label
          Positioned(
            top: 50,
            right: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'Image from Lorem Picsum',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Swipe Navigation Hint
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Swipe up for next quote",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : Container(
        width: width,
        height: height,
        color: Colors.black,
        child: const Center(
          child: SpinKitFadingCircle(
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }

  /// Load images from Lorem Picsum with BlurHash
  void _loadImagesFromPicsum() async {
    try {
      List<Map<String, dynamic>> images = [];

      for (int i = 0; i < 30; i++) {
        int randomId = _random.nextInt(1000) + 1;
        String imageUrl = 'https://picsum.photos/id/$randomId/800/1200';

        if (i % 3 == 0) {
          imageUrl = 'https://picsum.photos/800/1200?random=$randomId';
        }

        String blurHash = _defaultBlurHashes[_random.nextInt(_defaultBlurHashes.length)];

        images.add({
          'id': randomId.toString(),
          'url': imageUrl,
          'blur_hash': blurHash,
        });
      }

      setState(() {
        imageList = images;
      });
    } catch (e) {
      print('Error loading images: $e');
      _createFallbackImages();
    }
  }

  /// Create fallback images if API fails
  void _createFallbackImages() {
    List<Map<String, dynamic>> fallbackImages = [];

    for (int i = 0; i < 30; i++) {
      int randomId = _random.nextInt(1000) + 1;
      String imageUrl = 'https://picsum.photos/800/1200?random=$randomId';
      String blurHash = _defaultBlurHashes[_random.nextInt(_defaultBlurHashes.length)];

      fallbackImages.add({
        'id': randomId.toString(),
        'url': imageUrl,
        'blur_hash': blurHash,
      });
    }

    setState(() {
      imageList = fallbackImages;
    });
  }
}
