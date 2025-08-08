import 'dart:math';
import 'package:flutter/material.dart';

class DemoScreen1 extends StatefulWidget {
  const DemoScreen1({super.key});

  @override
  State<DemoScreen1> createState() => _DemoScreen1State();
}

class _DemoScreen1State extends State<DemoScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F6FF),
        surfaceTintColor: const Color(0xFFF9F6FF),
        toolbarHeight: 45,
        leading: IconButton(
          padding: EdgeInsets.zero,
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.black,
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF9F6FF),
            expandedHeight: 270,
            flexibleSpace: FlexibleSpaceBar(background: _randomPlaceholder()),
            leading: const SizedBox(),
          ),
          SliverAppBar(
            toolbarHeight: 30,
            backgroundColor: const Color(0xFFF9F6FF),
            flexibleSpace: FlexibleSpaceBar(background: _randomPlaceholder()),
            leading: const SizedBox(),
          ),
          SliverAppBar(
            backgroundColor: const Color(0xFFF9F6FF),
            expandedHeight: 90,
            flexibleSpace: FlexibleSpaceBar(background: _randomPlaceholder()),
            leading: const SizedBox(),
          ),
          SliverAppBar(
            toolbarHeight: 45,
            backgroundColor: const Color(0xFFF9F6FF),
            flexibleSpace: FlexibleSpaceBar(background: _randomPlaceholder()),
            leading: const SizedBox(),
          ),
          SliverFillRemaining(
            fillOverscroll: true,
            child: const PropertyDetailsPage(),
          ),
        ],
      ),
    );
  }

  Widget _randomPlaceholder() {
    final random = Random();
    return Container(
      color: Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
    );
  }
}

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<String> tabs = [
    'Overview',
    'Highlights',
    'Project Tour',
    'Data Insights',
  ];

  final List<GlobalKey> sectionKeys = [];

  bool userTappedTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    sectionKeys.addAll(List.generate(tabs.length, (_) => GlobalKey()));
    _scrollController.addListener(_onScroll);
  }

  void _onTabTapped(int index) {
    userTappedTab = true;
    _tabController.animateTo(index);
    _scrollToSection(index);
    Future.delayed(const Duration(milliseconds: 400), () {
      userTappedTab = false;
    });
  }

  void _scrollToSection(int index) {
    final keyContext = sectionKeys[index].currentContext;
    if (keyContext != null) {
      final renderBox = keyContext.findRenderObject()! as RenderBox;
      final offset =
          renderBox
              .localToGlobal(Offset.zero, ancestor: context.findRenderObject())
              .dy;
      final scrollOffset = _scrollController.offset;
      final targetOffset = scrollOffset + offset - 100;

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onScroll() {
    if (userTappedTab) return;

    for (int i = 0; i < sectionKeys.length; i++) {
      final ctx = sectionKeys[i].currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject()! as RenderBox;
        final offset = box.localToGlobal(Offset.zero).dy;
        if (offset >= 0 && offset < MediaQuery.of(ctx).size.height / 2) {
          if (_tabController.index != i) {
            _tabController.animateTo(i);
          }
          break;
        }
      }
    }
  }

  Widget _randomSection(GlobalKey key) {
    final random = Random();
    return Container(
      key: key,
      height: random.nextInt(300) + 150, // 150–450px
      color: Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColoredBox(
          color: const Color(0xFFF9F6FF),
          child: TabBar(
            controller: _tabController,
            onTap: _onTabTapped,
            isScrollable: true,
            labelColor: const Color(0xFF5827BF),
            unselectedLabelColor: const Color(0xFF403D4E),
            indicatorColor: const Color(0xFF5827BF),
            dividerHeight: 0.7,
            labelPadding: const EdgeInsets.symmetric(horizontal: 15),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 4,
            indicatorPadding: const EdgeInsets.all(1),
            tabs:
                tabs
                    .map((t) => SizedBox(height: 30, child: Tab(text: t)))
                    .toList(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _randomSection(sectionKeys[0]),
                _randomSection(sectionKeys[1]),
                _randomSection(sectionKeys[2]),
                _randomSection(sectionKeys[3]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
