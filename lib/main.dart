import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SpotifyApp());
}

class SpotifyApp extends StatelessWidget {
  const SpotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotify Clone',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const SpotifyHomeScreen(),
    );
  }
}

class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class SpotifyHomeScreen extends StatefulWidget {
  const SpotifyHomeScreen({super.key});

  @override
  State<SpotifyHomeScreen> createState() => _SpotifyHomeScreenState();
}

class _SpotifyHomeScreenState extends State<SpotifyHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.space): const PlayPauseIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PlayPauseIntent: CallbackAction<PlayPauseIntent>(
            onInvoke: (intent) {
              debugPrint('Play/Pause triggered via Spacebar');
              return null;
            },
          ),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            if (width < 600) {
              return _buildMobileLayout();
            } else if (width < 840) {
              return _buildTabletLayout();
            } else {
              return _buildDesktopLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: const SpotifyContent(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black.withOpacity(0.9),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Your Library'),
              BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: TabletSidebar(
              selectedIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
          const VerticalDivider(thickness: 0.5, width: 0.5, color: Colors.grey),
          const Expanded(child: SpotifyContent()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(
                  width: 280,
                  child: SidebarLibrary(),
                ),
                const Expanded(child: SpotifyContent()),
                if (MediaQuery.sizeOf(context).width > 1100)
                  const SizedBox(
                    width: 300,
                    child: RightPanel(),
                  ),
              ],
            ),
          ),
          const FullPlayer(),
        ],
      ),
    );
  }
}

class TabletSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const TabletSidebar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          _navItem(Icons.home_filled, 'Home', 0),
          _navItem(Icons.search, 'Search', 1),
          _navItem(Icons.library_music, 'Your Library', 2),
          _navItem(Icons.add_box, 'Create', 3),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.blueGrey[800],
                    child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Somewhere I Belong', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Linkin Park', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    Icon(Icons.add_circle_outline, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(value: 0.3, onChanged: (v) {}),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0:03', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('-3:00', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.skip_previous, size: 32),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.black, size: 32),
                    ),
                    const Icon(Icons.skip_next, size: 32),
                  ],
                ),
                const SizedBox(height: 12),
                const Icon(Icons.devices, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class SpotifyContent extends StatelessWidget {
  const SpotifyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: TopAppBar()),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: FilterChips()),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => QuickPlayItem(index: index),
              childCount: 8,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SectionHeader(title: 'Picked for you')),
        const SliverToBoxAdapter(child: FeaturedCard()),
        const SliverToBoxAdapter(child: SectionHeader(title: 'Jump back in')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) => AlbumCard(index: index),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isFocused ? Colors.grey[800] : Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                      border: isFocused ? Border.all(color: Colors.white, width: 1) : null,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 20, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('What do you want to play?', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.notifications_none, color: Colors.white),
          const SizedBox(width: 12),
          const Icon(Icons.history, color: Colors.white),
        ],
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        _chip('All', isSelected: true),
        _chip('Music'),
        _chip('Podcasts'),
      ],
    );
  }

  Widget _chip(String label, {bool isSelected = false}) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: isSelected ? const Color(0xFF1DB954) : Colors.grey[900],
      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class QuickPlayItem extends StatelessWidget {
  final int index;
  const QuickPlayItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // แก้ไข: ปรับเป็นสี่เหลี่ยมจัตุรัส (Square)
            Container(
              width: 56, // กว้างเท่ากับความสูงเดิมเพื่อให้เป็นสี่เหลี่ยมจัตุรัส
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Playlist Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                ),
                child: const Center(child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Playlist', style: TextStyle(fontSize: 12)),
                    const Text('ฉันฟังเพลงไทย', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('เพลงไทยฮิตล่าสุด ฟังได้ที่นี่เลย!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    const Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.grey),
                        Spacer(),
                        Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  final int index;
  const AlbumCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: 160,
            color: Colors.primaries[index % Colors.primaries.length],
            child: const Icon(Icons.album, size: 80, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          const Text('Daily Mix 1', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Artist, Artist, Artist', style: TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2),
        ],
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF4C4C4C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(width: 40, height: 40, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Somewhere I Belong', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Linkin Park', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.devices, color: Colors.white),
          const SizedBox(width: 16),
          const Icon(Icons.play_arrow, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

class FullPlayer extends StatelessWidget {
  const FullPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85, 
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.music_note, size: 36),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Track Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                      Text('Artist Name', style: TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.favorite_border, size: 16),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shuffle, size: 16, color: Colors.grey),
                    SizedBox(width: 16),
                    Icon(Icons.skip_previous, size: 22),
                    SizedBox(width: 16),
                    Icon(Icons.play_circle_fill, size: 30),
                    SizedBox(width: 16),
                    Icon(Icons.skip_next, size: 22),
                    SizedBox(width: 16),
                    Icon(Icons.repeat, size: 16, color: Colors.grey),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: Colors.white,
                  ),
                  child: SizedBox(
                    height: 20, 
                    child: Row(
                      children: [
                        const Text('0:00', style: TextStyle(fontSize: 9, color: Colors.grey)),
                        Expanded(
                          child: Slider(
                            value: 0.3,
                            onChanged: (v) {},
                          ),
                        ),
                        const Text('3:45', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.lyrics_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 10),
                Icon(Icons.queue_music, size: 16, color: Colors.grey),
                SizedBox(width: 10),
                Icon(Icons.devices, size: 16, color: Colors.grey),
                SizedBox(width: 10),
                Icon(Icons.volume_up, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                SizedBox(width: 70, child: LinearProgressIndicator(value: 0.7, color: Colors.white, backgroundColor: Colors.grey, minHeight: 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarLibrary extends StatelessWidget {
  const SidebarLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
            child: const Column(
              children: [
                Row(children: [Icon(Icons.home_filled), SizedBox(width: 16), Text('Home', style: TextStyle(fontWeight: FontWeight.bold))]),
                SizedBox(height: 16),
                Row(children: [Icon(Icons.search), SizedBox(width: 16), Text('Search', style: TextStyle(color: Colors.grey))]),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.library_music, color: Colors.grey),
                      SizedBox(width: 12),
                      Text('Your Library', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.add, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FilterChips(), 
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) => ListTile(
                        leading: Container(width: 40, height: 40, color: Colors.blueGrey),
                        title: Text('Playlist #$index', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                        subtitle: const Text('Playlist • User', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text('LA CANCIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Icon(Icons.more_horiz),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 250, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  const Text('About the artist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[800],
                    child: const Center(child: Icon(Icons.person, size: 100)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
