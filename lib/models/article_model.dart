import 'topic_model.dart';

class SeoData {
  final String primaryKeyword;
  final List<String> secondaryKeywords;
  final List<String> longTailKeywords;
  final String searchIntent;
  final String seoTitle;
  final String metaDescription;
  final String urlSlug;
  final String ogTitle;
  final String ogDescription;
  final String twitterTitle;
  final String twitterDescription;

  SeoData({
    required this.primaryKeyword,
    required this.secondaryKeywords,
    required this.longTailKeywords,
    required this.searchIntent,
    required this.seoTitle,
    required this.metaDescription,
    required this.urlSlug,
    required this.ogTitle,
    required this.ogDescription,
    required this.twitterTitle,
    required this.twitterDescription,
  });

  factory SeoData.fromJson(Map<String, dynamic> json) => SeoData(
        primaryKeyword: json['primaryKeyword'] ?? '',
        secondaryKeywords: List<String>.from(json['secondaryKeywords'] ?? []),
        longTailKeywords: List<String>.from(json['longTailKeywords'] ?? []),
        searchIntent: json['searchIntent'] ?? '',
        seoTitle: json['seoTitle'] ?? '',
        metaDescription: json['metaDescription'] ?? '',
        urlSlug: json['urlSlug'] ?? '',
        ogTitle: json['ogTitle'] ?? '',
        ogDescription: json['ogDescription'] ?? '',
        twitterTitle: json['twitterTitle'] ?? '',
        twitterDescription: json['twitterDescription'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'primaryKeyword': primaryKeyword,
        'secondaryKeywords': secondaryKeywords,
        'longTailKeywords': longTailKeywords,
        'searchIntent': searchIntent,
        'seoTitle': seoTitle,
        'metaDescription': metaDescription,
        'urlSlug': urlSlug,
        'ogTitle': ogTitle,
        'ogDescription': ogDescription,
        'twitterTitle': twitterTitle,
        'twitterDescription': twitterDescription,
      };
}

class BlogContent {
  final String title;
  final String introduction;
  final String fullArticleMarkdown;
  final List<String> faqItems;
  final List<String> internalLinkingSuggestions;
  final int wordCount;

  BlogContent({
    required this.title,
    required this.introduction,
    required this.fullArticleMarkdown,
    required this.faqItems,
    required this.internalLinkingSuggestions,
    required this.wordCount,
  });

  factory BlogContent.fromJson(Map<String, dynamic> json) => BlogContent(
        title: json['title'] ?? '',
        introduction: json['introduction'] ?? '',
        fullArticleMarkdown: json['fullArticleMarkdown'] ?? '',
        faqItems: List<String>.from(json['faqItems'] ?? []),
        internalLinkingSuggestions:
            List<String>.from(json['internalLinkingSuggestions'] ?? []),
        wordCount: json['wordCount'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'introduction': introduction,
        'fullArticleMarkdown': fullArticleMarkdown,
        'faqItems': faqItems,
        'internalLinkingSuggestions': internalLinkingSuggestions,
        'wordCount': wordCount,
      };
}

class BlogImageInfo {
  final String prompt;
  final String altText;
  final String caption;
  final String placement;

  BlogImageInfo({
    required this.prompt,
    required this.altText,
    required this.caption,
    required this.placement,
  });

  factory BlogImageInfo.fromJson(Map<String, dynamic> json) => BlogImageInfo(
        prompt: json['prompt'] ?? '',
        altText: json['altText'] ?? '',
        caption: json['caption'] ?? '',
        placement: json['placement'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'altText': altText,
        'caption': caption,
        'placement': placement,
      };
}

class ImagePackage {
  final BlogImageInfo featuredImage;
  final List<BlogImageInfo> supportingImages;

  ImagePackage({required this.featuredImage, required this.supportingImages});

  factory ImagePackage.fromJson(Map<String, dynamic> json) => ImagePackage(
        featuredImage: BlogImageInfo.fromJson(json['featuredImage'] ?? {}),
        supportingImages: (json['supportingImages'] as List? ?? [])
            .map((e) => BlogImageInfo.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'featuredImage': featuredImage.toJson(),
        'supportingImages': supportingImages.map((e) => e.toJson()).toList(),
      };
}

class ArticleMetadata {
  final String metaTitle;
  final String metaDescription;
  final List<String> tags;
  final List<String> categories;
  final Map<String, String> openGraphData;

  ArticleMetadata({
    required this.metaTitle,
    required this.metaDescription,
    required this.tags,
    required this.categories,
    required this.openGraphData,
  });

  factory ArticleMetadata.fromJson(Map<String, dynamic> json) =>
      ArticleMetadata(
        metaTitle: json['metaTitle'] ?? '',
        metaDescription: json['metaDescription'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        categories: List<String>.from(json['categories'] ?? []),
        openGraphData: Map<String, String>.from(json['openGraphData'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'metaTitle': metaTitle,
        'metaDescription': metaDescription,
        'tags': tags,
        'categories': categories,
        'openGraphData': openGraphData,
      };
}

enum PublishStatus { draft, saved, published, failed }

// ── AI Search Optimization Data ───────────────────────────────────────────────

class AiSearchOptimizationData {
  // AEO: Direct answer + featured snippet
  final String featuredSnippetAnswer;
  final String directAnswerSection;

  // Content summary & takeaways (LLMO + GEO)
  final String articleSummary;
  final List<String> keyTakeaways;

  // FAQ (AEO + Schema)
  final List<String> faqSection;

  // GEO: Citation-worthy references
  final List<String> sourcesAndReferences;

  // E-E-A-T signals
  final Map<String, String> eatSignals;

  // Schema Markup JSON-LD (Article + FAQPage + BreadcrumbList)
  final Map<String, dynamic> schemaMarkup;

  // LLMO: entity map & definitions
  final Map<String, String> llmFriendlyStructure;

  // AISEO: optimised SEO meta overrides
  final String optimizedSeoTitle;
  final String optimizedMetaDescription;
  final String optimizedUrlSlug;

  // Quality validation & scoring
  final Map<String, num> qualityScores;
  final Map<String, bool> qualityChecklist;

  AiSearchOptimizationData({
    required this.featuredSnippetAnswer,
    required this.directAnswerSection,
    required this.articleSummary,
    required this.keyTakeaways,
    required this.faqSection,
    required this.sourcesAndReferences,
    required this.eatSignals,
    required this.schemaMarkup,
    required this.llmFriendlyStructure,
    required this.optimizedSeoTitle,
    required this.optimizedMetaDescription,
    required this.optimizedUrlSlug,
    required this.qualityScores,
    required this.qualityChecklist,
  });

  factory AiSearchOptimizationData.fromJson(Map<String, dynamic> json) =>
      AiSearchOptimizationData(
        featuredSnippetAnswer: json['featuredSnippetAnswer'] ?? '',
        directAnswerSection: json['directAnswerSection'] ?? '',
        articleSummary: json['articleSummary'] ?? '',
        keyTakeaways: List<String>.from(json['keyTakeaways'] ?? []),
        faqSection: List<String>.from(json['faqSection'] ?? []),
        sourcesAndReferences:
            List<String>.from(json['sourcesAndReferences'] ?? []),
        eatSignals: Map<String, String>.from(json['eatSignals'] ?? {}),
        schemaMarkup: Map<String, dynamic>.from(json['schemaMarkup'] ?? {}),
        llmFriendlyStructure:
            Map<String, String>.from(json['llmFriendlyStructure'] ?? {}),
        optimizedSeoTitle: json['optimizedSeoTitle'] ?? '',
        optimizedMetaDescription: json['optimizedMetaDescription'] ?? '',
        optimizedUrlSlug: json['optimizedUrlSlug'] ?? '',
        qualityScores: Map<String, num>.from(json['qualityScores'] ?? {}),
        qualityChecklist:
            Map<String, bool>.from(json['qualityChecklist'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'featuredSnippetAnswer': featuredSnippetAnswer,
        'directAnswerSection': directAnswerSection,
        'articleSummary': articleSummary,
        'keyTakeaways': keyTakeaways,
        'faqSection': faqSection,
        'sourcesAndReferences': sourcesAndReferences,
        'eatSignals': eatSignals,
        'schemaMarkup': schemaMarkup,
        'llmFriendlyStructure': llmFriendlyStructure,
        'optimizedSeoTitle': optimizedSeoTitle,
        'optimizedMetaDescription': optimizedMetaDescription,
        'optimizedUrlSlug': optimizedUrlSlug,
        'qualityScores': qualityScores,
        'qualityChecklist': qualityChecklist,
      };
}

class Article {
  final String id;
  final Topic topic;
  final SeoData seo;
  final BlogContent content;
  final ImagePackage images;
  final ArticleMetadata metadata;
  final PublishStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? wordpressPostId;
  final String userId;
  // nullable → backward compat with existing Firestore docs
  final AiSearchOptimizationData? aiOptimization;

  Article({
    required this.id,
    required this.topic,
    required this.seo,
    required this.content,
    required this.images,
    required this.metadata,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.wordpressPostId,
    this.aiOptimization,
  });

  Article copyWith({
    PublishStatus? status,
    String? wordpressPostId,
    DateTime? updatedAt,
    AiSearchOptimizationData? aiOptimization,
  }) =>
      Article(
        id: id,
        topic: topic,
        seo: seo,
        content: content,
        images: images,
        metadata: metadata,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        userId: userId,
        wordpressPostId: wordpressPostId ?? this.wordpressPostId,
        aiOptimization: aiOptimization ?? this.aiOptimization,
      );

  factory Article.fromFirestore(Map<String, dynamic> json, String docId) =>
      Article(
        id: docId,
        topic: Topic.fromJson(json['topic'] ?? {}),
        seo: SeoData.fromJson(json['seo'] ?? {}),
        content: BlogContent.fromJson(json['content'] ?? {}),
        images: ImagePackage.fromJson(json['images'] ?? {}),
        metadata: ArticleMetadata.fromJson(json['metadata'] ?? {}),
        status: PublishStatus.values.firstWhere(
          (e) => e.name == (json['status'] ?? 'draft'),
          orElse: () => PublishStatus.draft,
        ),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
        userId: json['userId'] ?? '',
        wordpressPostId: json['wordpressPostId'],
        aiOptimization: json['aiOptimization'] != null
            ? AiSearchOptimizationData.fromJson(
                Map<String, dynamic>.from(json['aiOptimization']))
            : null,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'topic': topic.toJson(),
        'seo': seo.toJson(),
        'content': content.toJson(),
        'images': images.toJson(),
        'metadata': metadata.toJson(),
        if (wordpressPostId != null) 'wordpressPostId': wordpressPostId,
        if (aiOptimization != null) 'aiOptimization': aiOptimization!.toJson(),
      };
}
