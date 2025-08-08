import 'package:flutter/material.dart';

class DemoScreen2 extends StatefulWidget {
  const DemoScreen2({super.key});

  @override
  State<DemoScreen2> createState() => _DemoScreen2State();
}

class _DemoScreen2State extends State<DemoScreen2>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _nestedScrollController;

  final List<String> tabs = [
    'Overview',
    'Highlights',
    'Project Tour',
    'Data Insights',
  ];

  final List<GlobalKey> sectionKeys = [];
  final GlobalKey _tabsKey = GlobalKey();
  bool userTappedTab = false;

  // true while we are programmatically scrolling because of a tab tap

  // simple debounce so we don't spam tab changes during fast scroll

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _nestedScrollController = ScrollController();
    sectionKeys.addAll(List.generate(tabs.length, (_) => GlobalKey()));
    _nestedScrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // initial sync if needed
      _onScroll();
    });
  }

  @override
  void dispose() {
    _nestedScrollController.removeListener(_onScroll);
    _tabController.dispose();
    _nestedScrollController.dispose();
    super.dispose();
  }

  // Called when user taps a tab
  void _onTabTapped(int index) async {
    if (index == _tabController.index) return;

    userTappedTab = true;
    _tabController.animateTo(index);

    await _scrollToSection(index); // Wait until scroll completes

    // Give a tiny delay to avoid race condition with ScrollController
    await Future.delayed(const Duration(milliseconds: 150));
    userTappedTab = false;
  }

  Future<void> _scrollToSection(int index) async {
    final keyContext = sectionKeys[index].currentContext;
    if (keyContext != null) {
      await Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  void _onScroll() {
    if (userTappedTab) return; // Skip while user tapped tab

    int activeIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < sectionKeys.length; i++) {
      final context = sectionKeys[i].currentContext;
      if (context != null) {
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final distanceFromTop = position.dy - 100;

        if (distanceFromTop.abs() < minDistance && distanceFromTop <= 200) {
          minDistance = distanceFromTop.abs();
          activeIndex = i;
        }
      }
    }

    if (_tabController.index != activeIndex) {
      _tabController.animateTo(activeIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (w, i) {},
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6FF),
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: const Color(0xFFF9F6FF),
          surfaceTintColor: const Color(0xFFF9F6FF),
        ),
        body: NestedScrollView(
          controller: _nestedScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: const Color(0xFFF9F6FF),
                expandedHeight: 270,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    "https://fastly.picsum.photos/id/730/800/400.jpg?hmac=bOhadsNCkBj6H-NMsGiz_f2DYLQNtzEMbq4dQHsxtqc",
                    fit: BoxFit.cover,
                  ),
                ),
                leading: const SizedBox(),
              ),
              SliverAppBar(
                toolbarHeight: 30,
                backgroundColor: Colors.pink,
                flexibleSpace: FlexibleSpaceBar(background: Text("Offer")),
                leading: const SizedBox(),
              ),
              SliverAppBar(
                backgroundColor: Colors.purpleAccent,
                expandedHeight: 90,
                flexibleSpace: FlexibleSpaceBar(background: Text("Price")),
                leading: const SizedBox(),
              ),
              SliverAppBar(
                toolbarHeight: 30,
                backgroundColor: Colors.amber,
                flexibleSpace: FlexibleSpaceBar(background: Text("1 Bhk")),
                leading: const SizedBox(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  tabController: _tabController,
                  onTabTapped: _onTabTapped,
                  tabs: tabs,
                  tabsKey: _tabsKey,
                ),
              ),
            ];
          },
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification ||
                  notification is ScrollEndNotification) {
                _onScroll();
              }
              return false;
            },
            child: SingleChildScrollView(
              key: const PageStorageKey('property_desc_body'),
              padding: const EdgeInsets.only(top: 15, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: sectionKeys[0],
                    color: Colors.red,
                    height: 300,
                    child: Row(children: [Text("OverView")]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    key: sectionKeys[1],
                    color: Colors.yellow,
                    height: 300,
                    child: Row(children: [Text("Highlights")]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    key: sectionKeys[2],
                    color: Colors.blue,
                    height: 300,
                    child: Row(children: [Text("Project Tour")]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    key: sectionKeys[3],
                    color: Colors.green,
                    height: 300,
                    child: Row(children: [Text("Data Insights")]),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: const Color(0xFFF9F6FF),
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(onPressed: () {}, child: Text("button")),
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate({
    required this.tabController,
    required this.onTabTapped,
    required this.tabs,
    this.tabsKey,
  });

  final TabController tabController;
  final Function(int) onTabTapped;
  final List<String> tabs;
  final GlobalKey? tabsKey;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: const Color(0xFFF9F6FF),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            key: tabsKey,
            child: TabBar(
              controller: tabController,
              onTap: onTabTapped,
              padding: EdgeInsets.zero,
              isScrollable: true,
              labelColor: const Color(0xFF5827BF),
              unselectedLabelColor: const Color(0xFF403D4E),
              indicatorColor: const Color(0xFF5827BF),
              dividerColor: const Color(0xFF9E9E9E),
              dividerHeight: 0.7,
              labelPadding: const EdgeInsets.symmetric(horizontal: 15),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 4,
              indicatorPadding: const EdgeInsets.all(1),
              tabs: [
                for (final tab in tabs)
                  SizedBox(height: 30, child: Tab(text: tab)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
