import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';

// https://www.youtube.com/watch?v=SOE2VoTva7c

class ExploreScreen extends StatefulWidget {
  final User? user;
  const ExploreScreen({super.key, required this.user});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late ScrollController _scrollController;
  double _scrollControllerOffset = 0.0;

  _scrollListener() {
    setState(() {
      _scrollControllerOffset = _scrollController.offset;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                slivers: [
                  // SliverToBoxAdapter(
                  //   child: Container(
                  //     color: Colors.yellow,
                  //     height: MediaQuery.of(context).size.height * 1.5,
                  //     child: Center(
                  //       child: Text('BLARG'),
                  //     ),
                  //   ),
                  // ),
                  // Other Sliver Widgets
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                          child: const Center(
                            child: Text(
                              'This is an awesome platform',
                            ),
                          ),
                        ),
                        Container(
                          height: 1000,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              PreferredSize(
                  preferredSize: Size(MediaQuery.of(context).size.width, 20.0),
                  child: FadeAppBar(scrollOffset: _scrollControllerOffset))
            ],
          )),
    );
  }
}

class FadeAppBar extends StatelessWidget {
  final double scrollOffset;
  const FadeAppBar({super.key, required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 100.0,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
        color: Provider.of<ThemeManager>(context).isDark
            ? Colors.black
                .withOpacity((scrollOffset / 220).clamp(0, 1).toDouble())
            : Colors.white
                .withOpacity((scrollOffset / 400).clamp(0, 1).toDouble()),
        child: const SafeArea(
          child: SearchInput(),
        ),
      ),
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      title: SizedBox(
        width: double.infinity,
        height: 40,
        // color: Colors.red,
        child: Center(
          child: TextField(
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black54,
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: .1,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 0.4,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: .1,
                ),
              ),
              hintStyle: const TextStyle(color: Colors.grey),
              hintText: 'Search for something',
              prefixIcon: const Icon(
                FontAwesomeIcons.search,
                size: 16.0,
                color: Colors.grey,
              ),
              suffixIcon: const Icon(
                FontAwesomeIcons.cameraRetro,
                size: 20.0,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
