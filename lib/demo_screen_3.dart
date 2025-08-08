import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class DemoScreen3 extends StatefulWidget {
  const DemoScreen3({super.key});

  @override
  State<DemoScreen3> createState() => _DemoScreen3State();
}

class _DemoScreen3State extends State<DemoScreen3>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  final List<String> sections = [
    "Overview",
    "Highlights",
    "Reviews",
    "Gallery",
    "Contact",
  ];

  bool _userTappedTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sections.length, vsync: this);

    _positionsListener.itemPositions.addListener(() {
      if (_userTappedTab) return; // Don't update during manual scroll-to

      final positions = _positionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        // Find first visible section
        final firstVisible = positions
            .where((pos) => pos.itemLeadingEdge >= 0)
            .reduce(
              (min, pos) =>
                  pos.itemLeadingEdge < min.itemLeadingEdge ? pos : min,
            );

        if (_tabController.index != firstVisible.index) {
          _tabController.animateTo(firstVisible.index);
        }
      }
    });
  }

  void _onTabTapped(int index) async {
    _userTappedTab = true;
    _tabController.animateTo(index);

    await _scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    _userTappedTab = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text("My Page"),
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  "https://fastly.picsum.photos/id/730/800/400.jpg?hmac=bOhadsNCkBj6H-NMsGiz_f2DYLQNtzEMbq4dQHsxtqc",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                tabController: _tabController,
                onTabTapped: _onTabTapped,
                tabs: sections,
                // tabsKey: _tabsKey,
              ),
            ),
          ];
        },
        body: ScrollablePositionedList.builder(
          itemCount: sections.length,
          itemScrollController: _scrollController,
          itemPositionsListener: _positionsListener,
          itemBuilder: (context, index) {
            return Container(
              height: 600,
              color: Colors.primaries[index % Colors.primaries.length].shade200,
              alignment: Alignment.center,
              child: Text(
                sections[index],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
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
    // this.tabsKey,
  });

  final TabController tabController;
  final Function(int) onTabTapped;
  final List<String> tabs;
  // final GlobalKey? tabsKey;

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
            // key: tabsKey,
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
