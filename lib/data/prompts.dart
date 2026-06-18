/// All Gemini prompt templates used by the Blog Writer Agent
class Prompts {
  Prompts._();

  // ---------------------------------------------------------------------------
  // Step 2 — Topic Evaluation
  // ---------------------------------------------------------------------------
  static String trendEvaluationPrompt(List<String> rawTopics) => '''
You are an expert content strategist and SEO analyst. Evaluate the following trending topics and score each one.

Topics:
${rawTopics.map((t) => '- $t').join('\n')}

For each topic, provide a JSON object with these exact fields:
- title: string (the topic title)
- description: string (1-2 sentences about the topic)
- searchDemand: number between 0 and 1 (estimated monthly search volume potential)
- trendGrowth: number between 0 and 1 (how fast the trend is growing)
- competitionLevel: number between 0 and 1 (0 = low competition, 1 = very high competition)
- monetizationPotential: number between 0 and 1 (AdSense / affiliate potential)
- keywords: array of 3-5 related keywords

Return a JSON object with a single key "topics" containing an array of scored topics, sorted by overall opportunity score descending.
Only return valid JSON. No markdown, no explanation.
''';

  // ---------------------------------------------------------------------------
  // Step 3 — SEO Research
  // ---------------------------------------------------------------------------
  static String seoResearchPrompt(String topicTitle) => '''
You are an expert SEO researcher. Generate comprehensive SEO research for the following topic.

Topic: $topicTitle

Return a JSON object with these exact fields:
- primaryKeyword: string
- secondaryKeywords: array of 5-7 strings
- longTailKeywords: array of 5-8 strings
- searchIntent: string ("informational", "commercial", "transactional", or "navigational")
- seoTitle: string (50-60 chars, includes primary keyword)
- metaDescription: string (150-160 chars, compelling, includes primary keyword)
- urlSlug: string (lowercase, hyphens, no special chars)
- ogTitle: string (Open Graph title)
- ogDescription: string (Open Graph description)
- twitterTitle: string
- twitterDescription: string

Only return valid JSON. No markdown, no explanation.
''';

  // ---------------------------------------------------------------------------
  // Step 4 — Blog Content Generation
  // ---------------------------------------------------------------------------
  static String blogGenerationPrompt(String topicTitle, String primaryKeyword,
      List<String> secondaryKeywords) =>
      '''
You are an expert blog writer creating AdSense-friendly, EEAT-oriented content. Write a comprehensive, SEO-optimized blog article.

Topic: $topicTitle
Primary Keyword: $primaryKeyword
Secondary Keywords: ${secondaryKeywords.join(', ')}

Requirements:
- Minimum 1500 words
- Use proper heading hierarchy (H1, H2, H3)
- Include a compelling introduction
- Use bullet points and numbered lists where appropriate
- Include practical examples and actionable advice
- Write in first/second person, conversational but authoritative tone
- Include expertise signals (EEAT)
- End with a strong conclusion
- Include a FAQ section with 5-7 questions and detailed answers
- Suggest 3-5 internal linking opportunities (placeholder URLs)
- Format as Markdown

Return a JSON object with these exact fields:
- title: string (the article H1 title)
- introduction: string (first paragraph only)
- fullArticleMarkdown: string (complete article in Markdown, including title)
- faqItems: array of strings (each item is "Q: question\\nA: answer")
- internalLinkingSuggestions: array of strings
- wordCount: number (approximate word count)

Only return valid JSON. No markdown wrapping. No explanation.
''';

  // ---------------------------------------------------------------------------
  // Step 5 — Metadata Generation
  // ---------------------------------------------------------------------------
  static String metadataPrompt(String articleTitle, String primaryKeyword,
      String category) =>
      '''
You are an expert content metadata specialist. Generate complete metadata for this blog article.

Article Title: $articleTitle
Primary Keyword: $primaryKeyword
Category Hint: $category

Return a JSON object with these exact fields:
- metaTitle: string (SEO meta title, 50-60 chars)
- metaDescription: string (compelling meta description, 150-160 chars)
- tags: array of 8-12 strings (relevant tags)
- categories: array of 2-3 strings (WordPress categories)
- openGraphData: object with keys: og:title, og:description, og:type, og:locale

Only return valid JSON. No markdown, no explanation.
''';

  // ---------------------------------------------------------------------------
  // Step 6 — Image Prompt Generation
  // ---------------------------------------------------------------------------
  static String imagePromptGenerationPrompt(String topicTitle) => '''
You are an expert creative director specializing in blog imagery. Generate detailed image prompts for this blog article.

Topic: $topicTitle

Return a JSON object with these exact fields:
- featuredImage: object with:
  - prompt: string (detailed image generation prompt, vivid and specific)
  - altText: string (SEO-friendly alt text)
  - caption: string (engaging image caption)
  - placement: string ("hero" or "featured")
- supportingImages: array of 2-3 objects, each with:
  - prompt: string (detailed image generation prompt)
  - altText: string
  - caption: string
  - placement: string ("section-1", "section-2", etc.)

Make prompts photorealistic, modern, and professional. Include style, lighting, composition details.

Only return valid JSON. No markdown, no explanation.
''';
}
