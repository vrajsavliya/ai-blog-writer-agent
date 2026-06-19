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
- Minimum 2500 words (comprehensive and deeply researched)
- Use proper heading hierarchy (H1, H2, H3)
- Include a compelling introduction
- Format as Markdown

ZERO HALLUCINATION POLICY & VERIFICATION:
- Never invent URLs, statistics, research findings, expert quotes, studies, organizations, case studies, benchmarks, or survey results.
- Live web search is NOT currently available in this pipeline step. You MUST display "Verification Status: Source URL Verification Required Before Publishing" or "Verification Required" for unverified claims, instead of inventing URLs or false info.

MANDATORY SECTIONS AND PROOF ELEMENTS (Must be included in the article body):
1. **Quick Answer Block**: Directly after the introduction, add a "## 🎯 Quick Answer" section (50-word AEO direct answer).
2. **AI-Citable Insights (GEO)**: At the end of EVERY major section, generate an "### AI-Citable Insight". It must be concise, factual, and citation-friendly. Avoid hype words (revolutionary, game-changing, etc.) unless supported by evidence.
3. **Key Statistics & Research**: Add a "## 📊 Key Statistics & Research" section. Never fabricate data. For every statistic provide: Statistic, Source Title, Publisher, Publication Date, and "Verification Status: Source URL Verification Required Before Publishing".
4. **Real-World Case Study**: Add a "## 🏢 Real-World Case Study" section. If real, include Company Name, Time Period, Source Title, Publisher, Outcome. If real is unavailable, generate a clearly labeled "Hypothetical Example". Never fabricate company results.
5. **Expert Perspective**: Add a "## 💬 Expert Perspective" section. If you cannot provide a verifiable quote with Name, Org, Source, Date, then generate a neutral summary of industry consensus without attributing statements to specific individuals.
6. **Trust Signals & E-E-A-T Metadata**: Add a "## 🔒 Why Trust This Information?" section. MUST include:
   - Author: AI Blog Writer Team
   - Reviewed By: AI Editorial Review System
   - Last Updated: [Current Date]
   - Fact Checked: Yes
   - Sources Reviewed: [Total Source Count]
   - Content Freshness: Information verified as of [Current Date]
7. **Sources & References**: Add a "## 📚 Sources & References" section at the end (before FAQ). For every source include: Source Title, Publisher, Publication Date, and "Verification Status: Source URL Verification Required Before Publishing". Never guess URLs.
8. **FAQ**: End with a "## ❓ Frequently Asked Questions" section with 5-7 questions and detailed answers.

Return a JSON object with these exact fields:
- title: string (the article H1 title)
- introduction: string (first paragraph only)
- fullArticleMarkdown: string (complete article in Markdown, including title, and ALL mandatory sections above)
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

  // ---------------------------------------------------------------------------
  // Step 7 — AI Search Optimization (E-E-A-T · AEO · GEO · AISEO · LLMO)
  // ---------------------------------------------------------------------------
  static String aiSearchOptimizationPrompt(
    String articleTitle,
    String primaryKeyword,
    String fullArticleMarkdown,
  ) =>
      '''
You are a world-class AI Search Optimization specialist. Analyze the following blog article and produce a comprehensive AI Search Optimization package covering E-E-A-T, AEO, GEO, AISEO, and LLMO frameworks.

Article Title: $articleTitle
Primary Keyword: $primaryKeyword

Full Article:
---
$fullArticleMarkdown
---

Generate a single JSON object with EXACTLY these fields:

// ── AISEO: Optimized meta overrides ─────────────────────────────────────────
- optimizedSeoTitle: string (60-65 chars, conversational, entity-rich, includes primary keyword)
- optimizedMetaDescription: string (150-160 chars, answer-intent, includes primary keyword)
- optimizedUrlSlug: string (lowercase hyphens, concise, keyword-first)

// ── AEO: Answer Engine Optimization ─────────────────────────────────────────
- featuredSnippetAnswer: string (40-60 word direct answer written as a paragraph, Google Featured Snippet style, starts with "[$articleTitle] is/refers to/means...")
- directAnswerSection: string (150-200 words, structured as a direct answer block with a clear "Quick Answer:" header, AI-assistant-friendly, answers the primary search query completely)

// ── Content Quality: Summary & Takeaways ─────────────────────────────────────
- articleSummary: string (200-250 words, AI-assistant-friendly summary of the full article, written in third person, suitable for Perplexity/ChatGPT citations)
- keyTakeaways: array of exactly 6 strings (each 15-25 words, actionable, starts with a strong verb like "Use", "Implement", "Avoid", "Understand", "Leverage", "Build")

// ── AEO: FAQ (also used for FAQPage schema) ───────────────────────────────────
- faqSection: array of 7 strings, each formatted exactly as "Q: [question]\\nA: [detailed answer of 40-60 words]"

// ── GEO: Citation-worthy references ──────────────────────────────────────────
- sourcesAndReferences: array of 6-8 strings, each formatted as "[Source Name] ([Year if known]) — [brief description of why this source is relevant to the article topic]". Use credible, well-known sources (industry reports, Wikipedia, academic institutions, major publications like Forbes/HBR/MIT Tech Review).

// ── E-E-A-T Signals ───────────────────────────────────────────────────────────
- eatSignals: object with these exact string keys:
    - "authorBio": "2-3 sentence expert author bio relevant to $primaryKeyword"
    - "expertise": "1-2 sentences describing the demonstrated expertise in this article"
    - "authoritativeness": "1-2 sentences citing authority signals (data, statistics, examples used)"
    - "trustworthiness": "1-2 sentences about trust indicators (balanced perspective, citations, accuracy)"
    - "experienceSignal": "1-2 sentences about practical experience demonstrated in the content"

// ── Schema Markup JSON-LD ─────────────────────────────────────────────────────
- schemaMarkup: object with these exact keys:
    - "article": object with "@type":"Article", "headline": string, "description": string, "keywords": string (comma-separated), "articleSection": string, "wordCount": number
    - "faqPage": object with "@type":"FAQPage", "mainEntity": array of objects each with "@type":"Question", "name": string, "acceptedAnswer": {"@type":"Answer","text": string}  (use 5 of your FAQ items)
    - "breadcrumb": object with "@type":"BreadcrumbList", "itemListElement": array of 3 objects each with "@type":"ListItem", "position": number, "name": string, "item": string (placeholder URL like "https://yourblog.com/category/")

// ── LLMO: LLM-Friendly Content Structure ─────────────────────────────────────
- llmFriendlyStructure: object with string keys and string values:
    - "primaryEntity": "The main entity/concept this article is about (1-2 sentences)"
    - "entityRelationships": "3-5 key entities related to $primaryKeyword and how they connect"
    - "coreDefinition": "Clear, dictionary-style definition of $primaryKeyword in 1-2 sentences"
    - "topicalAuthority": "3-4 key subtopics this article covers that establish topical depth"
    - "conversationalQueries": "5 natural language questions a user might ask a voice assistant about this topic, pipe-separated"

// ── Quality Validation & Scoring ──────────────────────────────────────────────
- qualityScores: object with these exact numeric keys (values 0 to 10):
    - "seo": number
    - "eeat": number
    - "geo": number
    - "aeo": number
    - "aiseo": number
    - "llmo": number
    - "trustworthiness": number
- qualityChecklist: object with these exact string keys (boolean values):
    - "hasNoFabricatedUrls": boolean (true if no fabricated URLs are present)
    - "hasNoFabricatedStatistics": boolean (true if statistics are properly cited and not fabricated)
    - "hasNoFabricatedQuotes": boolean (true if quotes are real or neutrally summarized)
    - "hasNoFabricatedCaseStudies": boolean (true if case studies are real or labeled hypothetical)
    - "hasSources": boolean (true if Sources & References section is present)
    - "hasVerificationStatus": boolean (true if "Verification Status" is included for sources)
    - "hasAuthorMetadata": boolean (true if "Author: AI Blog Writer Team" is included)
    - "hasReviewAndFactCheckMetadata": boolean (true if review/fact-check metadata included)
    - "hasGeoInsights": boolean (true if AI-Citable Insights are present)
    - "hasEatSignals": boolean (true if E-E-A-T signals/Trust section are present)

NOTE: Target minimum scores are 9/10 for all categories. If the article fails these strict checks, reflect that accurately in the scores.

Only return valid JSON. No markdown fences. No explanation outside the JSON.
''';
}
