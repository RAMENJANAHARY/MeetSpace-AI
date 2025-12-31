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
                'https://upload.wikimedia.org/wikipedia/commons/6/6e/Avenue_des_Baobabs%2C_Morondava%2C_Madagascar.jpg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BaobabStory()),
            ),
          ),
          StoryCard(
            title: 'Babakoto – The Indri Legend',
            subtitle: 'Father of humanity',
            image:
                'https://upload.wikimedia.org/wikipedia/commons/5/5f/Indri_indri_%28Indri%29.jpg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IndriStory()),
            ),
          ),
          StoryCard(
            title: 'The Clever Chameleon',
            subtitle: 'Master of colors and patience',
            image:
                'https://upload.wikimedia.org/wikipedia/commons/9/9f/Panther_chameleon_%28Furcifer_pardalis%29_male.jpg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChameleonStory()),
            ),
          ),
          StoryCard(
            title: 'Malagasy Village Life',
            subtitle: 'Harmony with ancestors and nature',
            image:
                'https://upload.wikimedia.org/wikipedia/commons/7/7e/Malagasy_village.jpg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VillageStory()),
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
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
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

// Individual Story Screens
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
