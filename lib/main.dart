import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const AdhkarApp());
}

class AdhkarApp extends StatelessWidget {
  const AdhkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أذكار المسلم',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F4F4F)),
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      home: const AdhkarHomePage(),
    );
  }
}

class AdhkarHomePage extends StatefulWidget {
  const AdhkarHomePage({super.key});

  @override
  State<AdhkarHomePage> createState() => _AdhkarHomePageState();
}

class _AdhkarHomePageState extends State<AdhkarHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: adhkarCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أذكار المسلم اليومية'),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: adhkarCategories
              .map(
                (category) => Tab(text: category.title),
              )
              .toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث في الأذكار...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: adhkarCategories
                  .map((category) => AdhkarListView(
                        category: category,
                        query: _query,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AdhkarListView extends StatelessWidget {
  const AdhkarListView({
    super.key,
    required this.category,
    this.query = '',
  });

  final AdhkarCategory category;
  final String query;

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty
        ? category.adhkar
        : category.adhkar
            .where(
              (zikr) => zikr.matches(query),
            )
            .toList();

    if (filtered.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final zikr = filtered[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  zikr.title,
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  zikr.text,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (zikr.count != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text('التكرار: ${zikr.count}'),
                    ),
                  ),
                ],
                if (zikr.reference != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'المصدر: ${zikr.reference}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'لم يتم العثور على أذكار مطابقة.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AdhkarCategory {
  const AdhkarCategory({required this.title, required this.adhkar});

  final String title;
  final List<ZikrItem> adhkar;
}

class ZikrItem {
  const ZikrItem({
    required this.title,
    required this.text,
    this.count,
    this.reference,
  });

  final String title;
  final String text;
  final String? count;
  final String? reference;

  bool matches(String query) {
    return title.contains(query) || text.contains(query);
  }
}

final List<AdhkarCategory> adhkarCategories = [
  AdhkarCategory(
    title: 'أذكار الصباح',
    adhkar: [
      ZikrItem(
        title: 'أصبحنا وأصبح الملك لله',
        text:
            'أصبحنا وأصبح الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير...'
            ' اللهم إني أسألك خير هذا اليوم فتحه ونصره ونوره وبركته وهداه، وأعوذ بك من شر ما فيه وشر ما بعده.',
        reference: 'صحيح مسلم',
      ),
      ZikrItem(
        title: 'سيد الاستغفار',
        text:
            'اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت،'
            ' أبوء لك بنعمتك علي وأبوء بذنبي فاغفر لي، فإنه لا يغفر الذنوب إلا أنت.',
        count: 'مرة واحدة',
        reference: 'البخاري',
      ),
      ZikrItem(
        title: 'قراءة آية الكرسي',
        text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        count: 'مرة واحدة',
        reference: 'البقرة: 255',
      ),
    ],
  ),
  AdhkarCategory(
    title: 'أذكار المساء',
    adhkar: [
      ZikrItem(
        title: 'أمسينا وأمسى الملك لله',
        text:
            'أمسينا وأمسى الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير...'
            ' اللهم إني أسألك خير هذه الليلة فتحها ونصرها ونورها وبركتها وهداه، وأعوذ بك من شر ما فيها وشر ما بعدها.',
        reference: 'صحيح مسلم',
      ),
      ZikrItem(
        title: 'آية الكرسي',
        text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        count: 'مرة واحدة',
        reference: 'البقرة: 255',
      ),
      ZikrItem(
        title: 'المعوذات',
        text: 'سورة الإخلاص والمعوذتين، ثلاث مرات.',
        count: '3 مرات',
      ),
    ],
  ),
  AdhkarCategory(
    title: 'أذكار الاستيقاظ',
    adhkar: [
      ZikrItem(
        title: 'الحمد لله الذي أحيانا',
        text:
            'الحمد لله الذي أحيانا بعدما أماتنا وإليه النشور. لا إله إلا الله وحده لا شريك له، له الملك وله الحمد، وهو على كل شيء قدير. سبحان الله والحمد لله ولا إله إلا الله والله أكبر ولا حول ولا قوة إلا بالله.',
        reference: 'البخاري ومسلم',
      ),
      ZikrItem(
        title: 'دعاء الفزع من النوم',
        text: 'أعوذ بكلمات الله التامات من غضبه وعقابه وشر عباده ومن همزات الشياطين وأن يحضرون.',
      ),
    ],
  ),
  AdhkarCategory(
    title: 'أذكار النوم',
    adhkar: [
      ZikrItem(
        title: 'باسمك اللهم أموت وأحيا',
        text: 'باسمك اللهم أموت وأحيا.',
        reference: 'البخاري',
      ),
      ZikrItem(
        title: 'جمع الكفين والنفث فيهما',
        text: 'جمع الكفين والنفث فيهما بقراءة الإخلاص والفلق والناس ثم مسح الجسد ثلاث مرات.',
      ),
      ZikrItem(
        title: 'آية الكرسي قبل النوم',
        text: 'قراءة آية الكرسي قبل النوم تحفظ المسلم من الشيطان حتى يصبح.',
        reference: 'البخاري',
      ),
    ],
  ),
  AdhkarCategory(
    title: 'أذكار بعد الصلاة',
    adhkar: [
      ZikrItem(
        title: 'الاستغفار بعد الصلاة',
        text: 'أستغفر الله، أستغفر الله، أستغفر الله. اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام.',
      ),
      ZikrItem(
        title: 'التسبيح والتحميد والتكبير',
        text: 'سبحان الله (33 مرة)، الحمد لله (33 مرة)، الله أكبر (33 مرة)، ثم لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
      ),
      ZikrItem(
        title: 'قراءة المعوذات',
        text: 'سورة الإخلاص والمعوذتين مرة واحدة بعد كل صلاة.',
      ),
    ],
  ),
  AdhkarCategory(
    title: 'أذكار دخول المنزل والخروج منه',
    adhkar: [
      ZikrItem(
        title: 'دعاء دخول المنزل',
        text: 'اللهم إني أسألك خير المولج وخير المخرج، بسم الله ولجنا وبسم الله خرجنا وعلى الله ربنا توكلنا.',
      ),
      ZikrItem(
        title: 'ذكر الخروج من المنزل',
        text: 'بسم الله، توكلت على الله، ولا حول ولا قوة إلا بالله.',
        reference: 'أبو داود والترمذي',
      ),
    ],
  ),
  AdhkarCategory(
    title: 'أذكار الطعام',
    adhkar: [
      ZikrItem(
        title: 'دعاء قبل الطعام',
        text: 'بسم الله، اللهم بارك لنا فيما رزقتنا وقنا عذاب النار.',
      ),
      ZikrItem(
        title: 'دعاء بعد الطعام',
        text: 'الحمد لله الذي أطعمني هذا ورزقنيه من غير حول مني ولا قوة.',
        reference: 'أبو داود والترمذي',
      ),
    ],
  ),
  AdhkarCategory(
    title: 'أذكار عامة',
    adhkar: [
      ZikrItem(
        title: 'سبحان الله وبحمده',
        text: 'سبحان الله وبحمده، سبحان الله العظيم.',
        count: '100 مرة',
        reference: 'البخاري ومسلم',
      ),
      ZikrItem(
        title: 'لا حول ولا قوة إلا بالله',
        text: 'لا حول ولا قوة إلا بالله العلي العظيم.',
        reference: 'مسند أحمد',
      ),
    ],
  ),
];
