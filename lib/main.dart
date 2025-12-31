import 'package:flutter/material.dart';

void main() {
  runApp(const MadagascarStoriesApp());
}

class MadagascarStoriesApp extends StatelessWidget {
  const MadagascarStoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madagascar Stories',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green[800]!),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          'Madagascar Legends & Wonders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Discover the magic of Madagascar through ancient tales and unique wildlife!',
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          StoryCard(
            title: 'The Proud Baobab Trees',
            subtitle: 'Why they grow upside down',
            image:
                'https://as2.ftcdn.net/v2/jpg/01/63/23/53/1000_F_163235373_Xzz4MLDDFGhBbM7tqsMYSNB0aueQYxFv.jpg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BaobabStory()),
            ),
          ),
          StoryCard(
            title: 'Babakoto – The Indri Legend',
            subtitle: 'Father of humanity',
            image:
                'https://media.istockphoto.com/id/1126116540/photo/beautiful-image-of-the-indri-lemur-sitting-on-tree-in-madagascar.jpg?s=612x612&w=0&k=20&c=ZGFxiowv-ahK86qbLDEwDpfBEZfDPMVVqC5z1cndBq0=',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IndriStory()),
            ),
          ),
          StoryCard(
            title: 'The Clever Chameleon',
            subtitle: 'Master of colors and patience',
            image:
                'https://www.madamagazine.com/wp-content/uploads/Furcifer-pardalis-Ambilobe-male-2019-2.jpg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChameleonStory()),
            ),
          ),
          StoryCard(
            title: 'Malagasy Village Life',
            subtitle: 'Harmony with ancestors and nature',
            image:
                'https://media.istockphoto.com/id/506751044/photo/malagasy-traditional-village.jpg?s=612x612&w=0&k=20&c=R3hYqC7g6zrjsOlj2nyCJwZPfPGWTYnrqUO83hfDMdQ=',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VillageStory()),
            ),
          ),
          StoryCard(
            title: 'Ring-Tailed Lemurs',
            subtitle: 'The social queens of the south',
            image:
                'https://media.gettyimages.com/id/482738815/photo/ring-tailed-lemurs-madagascar.jpg?s=612x612&w=gi&k=20&c=7IS4gOwI3HSvME4SnvZHlwoL4Yut-giLtaQUFxu5POM=',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RingTailedLemurStory()),
            ),
          ),
          StoryCard(
            title: 'Tsingy – The Stone Forest',
            subtitle: 'Razor-sharp labyrinth of limestone',
            image: 'https://static.toiimg.com/photo/107857557.cms',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TsingyStory()),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Image.network(
                image,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 240,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Existing Story Screens (unchanged)
class BaobabStory extends StatelessWidget {
  const BaobabStory({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Proud Baobab Trees')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'In ancient times, the baobab was the most arrogant tree. It complained to God that it wanted beautiful flowers, tall height, and sweet fruit like others.\n\n'
          'Angry at its pride, God pulled it from the earth and planted it upside down. That is why the baobab\'s branches look like roots reaching to the sky.\n\n'
          'Today, the Avenue of the Baobabs is one of the most breathtaking roads in the world, especially at sunset.',
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ),
    );
  }
}

class IndriStory extends StatelessWidget {
  const IndriStory({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Babakoto – Father of Man')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'A long-lost boy was raised by indri lemurs in the rainforest. He learned their songs and lived among them.\n\n'
          'The Malagasy call the indri "Babakoto" — Father of Man — because they believe humans and indris share an ancient bond.\n\n'
          'Their haunting, whale-like calls echo through the misty eastern forests at dawn.',
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ),
    );
  }
}

class ChameleonStory extends StatelessWidget {
  const ChameleonStory({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Clever Chameleon')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'Madagascar is home to over half the world\'s chameleon species. These patient hunters can move their eyes independently and change color to communicate.\n\n'
          'In folklore, the chameleon teaches wisdom: slow movement, careful observation, and adaptation to survive.\n\n'
          'From the tiny leaf chameleon to the vibrant panther chameleon, they are living art.',
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ),
    );
  }
}

class VillageStory extends StatelessWidget {
  const VillageStory({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Malagasy Village Life')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'Life revolves around family, ancestors, and nature. Rice fields terrace the hills, and sacred forests protect spirits.\n\n'
          'During famadihana ceremonies, families dance with ancestors\' bones to honor them.\n\n'
          'Stories are shared under baobab trees at night — keeping traditions alive for generations.',
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ),
    );
  }
}

// New Story Screens
class RingTailedLemurStory extends StatelessWidget {
  const RingTailedLemurStory({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ring-Tailed Lemurs')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'The iconic ring-tailed lemurs live in troops led by females. They spend more time on the ground than most lemurs and love sunbathing with arms outstretched.\n\n'
          'In Malagasy culture, they are playful spirits of the dry southern forests. Their black-and-white tails are used for "stink fights" to establish dominance!\n\n'
          'Watching a group basking under the morning sun is pure Madagascar magic.',
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ),
    );
  }
}

class TsingyStory extends StatelessWidget {
  const TsingyStory({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tsingy – The Stone Forest')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'The Tsingy de Bemaraha is a UNESCO World Heritage site — a vast labyrinth of razor-sharp limestone pinnacles formed over millions of years.\n\n'
          'Meaning "where one cannot walk barefoot," these needle-like rocks create hidden forests, caves, and canyons teeming with unique wildlife.\n\n'
          'Adventurers cross suspended bridges and climb through this otherworldly landscape — one of Earth\'s most extraordinary natural wonders.',
          style: TextStyle(fontSize: 18, height: 1.8),
        ),
      ),
    );
  }
}
