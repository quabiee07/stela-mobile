class StoryType {
  final String name;
  final String asset;

  StoryType({required this.name, required this.asset});

  static List<StoryType> storyTypes = [
    StoryType(name: "Adventure", asset: "🚀"),
    StoryType(name: "Magic", asset: "🦄"),
    StoryType(name: "Funny", asset: "😂"),
    StoryType(name: "Superheroes", asset: "🦸"),
    StoryType(name: "Mystery", asset: "🕵️‍♂️"),
    StoryType(name: "Fantasy", asset: "🐉"),
  ];
}