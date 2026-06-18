class Topic {
  final String title;
  final String description;
  final double searchDemand;
  final double trendGrowth;
  final double competitionLevel;
  final double monetizationPotential;
  final List<String> keywords;

  Topic({
    required this.title,
    required this.description,
    required this.searchDemand,
    required this.trendGrowth,
    required this.competitionLevel,
    required this.monetizationPotential,
    required this.keywords,
  });

  double get score =>
      (searchDemand + trendGrowth + (1 - competitionLevel) + monetizationPotential) / 4;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      searchDemand: (json['searchDemand'] ?? 0.5).toDouble(),
      trendGrowth: (json['trendGrowth'] ?? 0.5).toDouble(),
      competitionLevel: (json['competitionLevel'] ?? 0.5).toDouble(),
      monetizationPotential: (json['monetizationPotential'] ?? 0.5).toDouble(),
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'searchDemand': searchDemand,
        'trendGrowth': trendGrowth,
        'competitionLevel': competitionLevel,
        'monetizationPotential': monetizationPotential,
        'keywords': keywords,
        'score': score,
      };
}
