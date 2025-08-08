import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class DemoScreen4 extends StatefulWidget {
  const DemoScreen4({super.key});

  @override
  State<DemoScreen4> createState() => _DemoScreen4State();
}

class _DemoScreen4State extends State<DemoScreen4>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AutoScrollController _nestedScrollController;

  final List<String> tabs = [
    'Overview',
    'Highlights',
    'Project Tour',
    'Data Insights',
  ];

  bool userTappedTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _nestedScrollController = AutoScrollController();
    _nestedScrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // if (index == _tabController.index) return;

    userTappedTab = true;
    _tabController.animateTo(index);

    await _nestedScrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 400),
    );

    await Future.delayed(const Duration(milliseconds: 150));
    userTappedTab = false;
  }

  void _onScroll() {
    if (userTappedTab) return;

    int activeIndex = 0;
    double minOffset = double.infinity;

    for (int i = 0; i < tabs.length; i++) {
      final RenderBox? box =
          _nestedScrollController.tagMap[i]?.context.findRenderObject()
              as RenderBox?;
      if (box != null) {
        final offset = box.localToGlobal(Offset.zero).dy;
        if ((offset - 100).abs() < minOffset && offset <= 200) {
          minOffset = (offset - 100).abs();
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
                flexibleSpace: const FlexibleSpaceBar(
                  background: Text("Offer"),
                ),
                leading: const SizedBox(),
              ),
              SliverAppBar(
                backgroundColor: Colors.purpleAccent,
                expandedHeight: 90,
                flexibleSpace: const FlexibleSpaceBar(
                  background: Text("Price"),
                ),
                leading: const SizedBox(),
              ),
              SliverAppBar(
                toolbarHeight: 30,
                backgroundColor: Colors.amber,
                flexibleSpace: const FlexibleSpaceBar(
                  background: Text("1 Bhk"),
                ),
                leading: const SizedBox(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  tabController: _tabController,
                  onTabTapped: _onTabTapped,
                  tabs: tabs,
                ),
              ),
            ];
          },
          body: ListView(
            padding: const EdgeInsets.only(top: 15, bottom: 20),
            children: [
              AutoScrollTag(
                key: ValueKey(0),
                controller: _nestedScrollController,
                index: 0,
                child: Container(
                  color: Colors.red,
                  height: 300,
                  child: const Row(children: [Text("OverView")]),
                ),
              ),
              const SizedBox(height: 20),
              AutoScrollTag(
                key: ValueKey(1),
                controller: _nestedScrollController,
                index: 1,
                child: Container(
                  color: Colors.yellow,
                  height: 300,
                  child: const Row(children: [Text("Highlights")]),
                ),
              ),
              const SizedBox(height: 20),
              AutoScrollTag(
                key: ValueKey(2),
                controller: _nestedScrollController,
                index: 2,
                child: Container(
                  color: Colors.blue,
                  height: 300,
                  child: const Row(children: [Text("Project Tour")]),
                ),
              ),
              const SizedBox(height: 20),
              AutoScrollTag(
                key: ValueKey(3),
                controller: _nestedScrollController,
                index: 3,
                child: Container(
                  color: Colors.green,
                  height: 300,
                  child: const Row(children: [Text("Data Insights")]),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: const Color(0xFFF9F6FF),
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(onPressed: () {}, child: const Text("button")),
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
  });

  final TabController tabController;
  final Function(int) onTabTapped;
  final List<String> tabs;

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
          TabBar(
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
