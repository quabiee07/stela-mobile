import 'package:stela_mobile/core/presentation/resources/drawables.dart';
import 'package:stela_mobile/features/dashboard/domain/models/story.dart';

class HomeState {
  int selectedIndex = 0;
  String firstName = '';
  String profilePicture = '';
  final List<Story> mockStories = [
    const Story(
      id: '1',
      title: 'The Dragon Who Lost His Roar',
      author: 'by Sofia Chen',
      coverImage: boyDragon,
      tags: 'Fantasy. Ages 6-9',
      readTime: '8 min read',
      category: 'Fantasy',
      fullText:
          '''Once upon a time, in the rugged peaks of the Firestone Mountains, lived a young dragon named Ignis. Unlike the other dragons who could roar loud enough to shake the valleys, Ignis could only manage a tiny, high-pitched squeak.
The older dragons would often tease him, but Ignis didn't let that stop him. He would practice every morning at the edge of the highest cliff, taking deep breaths and pushing as hard as he could, hoping for a mighty roar to emerge.
One brisk autumn morning, a thick, enchanted fog rolled into the mountains, trapping a group of younger dragons who had strayed too far from the caves. They couldn't see their way back and their calls for help were muffled by the dense mist.
Ignis knew this was a dangerous situation. The older dragons were too far away to hear the lost youngsters. He flew as fast as his wings could carry him towards the cries. But how could he guide them back without a powerful roar?
He took the deepest breath he had ever taken, closing his eyes and drawing upon every ounce of courage in his small body. As he opened his mouth, it wasn't a roar that erupted, but a brilliant, piercing beam of golden fire!
The light cut through the enchanted fog like a beacon. The lost dragons saw the brilliant glow and followed it safely back to the caves.
From that day on, the other dragons never teased Ignis again. He might have lost his roar, but he found a light that could guide them all.''',
      currentChapter: 'Chapter 1',
      pageInfo: 'Page 1 of 70',
    ),
    const Story(
      id: '2',
      title: 'Unicorn Valley',
      author: 'by Mia torres',
      coverImage: pikinChase,
      tags: 'Fantasy. Ages 5-8',
      readTime: '4 min left',
      category: 'Fantasy',
      readPercentage: 0.65,
      fullText:
          '''Deep in the heart of Unicorn Valley, where the rivers flowed with sparkling pink lemonade and the trees grew cotton candy leaves, lived a curious young unicorn named Bella.
Bella wasn't like the other unicorns who spent their days galloping through the marshmallow meadows. She preferred to sit quietly by the Peppermint River, watching the sugar plum fairies dance on the water lilies.
One day, while exploring near the edge of the valley, Bella found a mysterious glowing stone. It was pulsing with a soft, warm light that seemed to hum a gentle melody. She carefully nudged it with her sparkling horn.
To her surprise, the stone burst open in a shower of glittering dust, revealing a tiny, sleeping crystal dragon! Bella gasped in pure delight. She knew this was the beginning of an incredible new adventure, right here in Unicorn Valley.''',
      currentChapter: 'Chapter 2',
      pageInfo: 'Page 12 of 30',
    ),
    const Story(
      id: '3',
      title: 'Beep the Little Robot',
      author: 'by Mia torres',
      coverImage: smilingRobot,
      tags: 'Adventure. Ages 4-7',
      readTime: '4 min left',
      category: 'Adventure',
      readPercentage: 0.65,
      fullText:
          '''In the bustling city of Mechaton, where gears turned clockwise and everything ran on a strict schedule, lived a small, square robot named Beep.
Beep was a sorting robot. His job was simple: pick up red blocks and put them in the red bin. Every day, it was the same routine. But Beep had a glitch. A wonderful, colorful glitch. Sometimes, his optic sensors would focus on the blue sky instead of the blocks.
One Tuesday sector-cycle, a rogue butterfly fluttered into the sorting factory. It was vibrant orange, contrasting sharply against the dull grey metal of the machinery. Beep stopped sorting red blocks.
His internal processors whirred loudly as he calculated the butterfly's flight path. Abandoning his station, Beep extend his gripping claws gently and followed the delicate creature through the factory doors.
For the first time in his operational life, Beep rolled onto the soft green grass outside. He beeped cheerfully. The world was so much bigger than the sorting factory, and he was ready to explore every colorful inch of it!''',
      currentChapter: 'Chapter 4',
      pageInfo: 'Page 20 of 40',
    ),
    const Story(
      id: '4',
      title: 'Moon Jumper',
      author: 'by Mia torres',
      coverImage: aiCartoon,
      tags: 'Adventure. Ages 6-10',
      readTime: '10 min read',
      category: 'Adventure',
      fullText:
          '''In the bustling city of Mechaton, where gears turned clockwise and everything ran on a strict schedule, lived a small, square robot named Beep.
Beep was a sorting robot. His job was simple: pick up red blocks and put them in the red bin. Every day, it was the same routine. But Beep had a glitch. A wonderful, colorful glitch. Sometimes, his optic sensors would focus on the blue sky instead of the blocks.
One Tuesday sector-cycle, a rogue butterfly fluttered into the sorting factory. It was vibrant orange, contrasting sharply against the dull grey metal of the machinery. Beep stopped sorting red blocks.
His internal processors whirred loudly as he calculated the butterfly's flight path. Abandoning his station, Beep extend his gripping claws gently and followed the delicate creature through the factory doors.
For the first time in his operational life, Beep rolled onto the soft green grass outside. He beeped cheerfully. The world was so much bigger than the sorting factory, and he was ready to explore every colorful inch of it!''',
      currentChapter: 'Chapter 1',
      pageInfo: 'Page 1 of 50',
    ),
    const Story(
      id: '5',
      title: 'Moon Jumper',
      author: 'by Mia torres',
      coverImage: childrenWolf,
      tags: 'Adventure. Ages 6-10',
      readTime: '10 min read',
      category: 'Adventure',
      fullText:
          '''In the bustling city of Mechaton, where gears turned clockwise and everything ran on a strict schedule, lived a small, square robot named Beep.
Beep was a sorting robot. His job was simple: pick up red blocks and put them in the red bin. Every day, it was the same routine. But Beep had a glitch. A wonderful, colorful glitch. Sometimes, his optic sensors would focus on the blue sky instead of the blocks.
One Tuesday sector-cycle, a rogue butterfly fluttered into the sorting factory. It was vibrant orange, contrasting sharply against the dull grey metal of the machinery. Beep stopped sorting red blocks.
His internal processors whirred loudly as he calculated the butterfly's flight path. Abandoning his station, Beep extend his gripping claws gently and followed the delicate creature through the factory doors.
For the first time in his operational life, Beep rolled onto the soft green grass outside. He beeped cheerfully. The world was so much bigger than the sorting factory, and he was ready to explore every colorful inch of it!''',
      currentChapter: 'Chapter 1',
      pageInfo: 'Page 1 of 50',
    ),
    const Story(
      id: '6',
      title: 'Moon Jumper',
      author: 'by Mia torres',
      coverImage: theBesties,
      tags: 'Adventure. Ages 6-10',
      readTime: '10 min read',
      category: 'Adventure',
      fullText:
          '''In the bustling city of Mechaton, where gears turned clockwise and everything ran on a strict schedule, lived a small, square robot named Beep.
Beep was a sorting robot. His job was simple: pick up red blocks and put them in the red bin. Every day, it was the same routine. But Beep had a glitch. A wonderful, colorful glitch. Sometimes, his optic sensors would focus on the blue sky instead of the blocks.
One Tuesday sector-cycle, a rogue butterfly fluttered into the sorting factory. It was vibrant orange, contrasting sharply against the dull grey metal of the machinery. Beep stopped sorting red blocks.
His internal processors whirred loudly as he calculated the butterfly's flight path. Abandoning his station, Beep extend his gripping claws gently and followed the delicate creature through the factory doors.
For the first time in his operational life, Beep rolled onto the soft green grass outside. He beeped cheerfully. The world was so much bigger than the sorting factory, and he was ready to explore every colorful inch of it!''',
      currentChapter: 'Chapter 1',
      pageInfo: 'Page 1 of 50',
    ),
  ];
}
