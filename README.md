# AI Blog Writer Agent

An AI-powered blog generation system built with **Flutter**, **Firebase**, **Gemini API**, and **Tavily Search API**. The agent automatically discovers trending topics, evaluates search demand, generates SEO-optimized content, creates metadata, prepares image prompts, and publishes articles to a website.

---

# Features

## Trend Discovery

* Fetches latest trending topics from the web using Tavily Search.
* Analyzes news, technology updates, AI trends, startup ecosystem, and developer communities.
* Identifies high-potential content opportunities.

## Topic Selection

* Evaluates topics based on:

  * Search Demand
  * Trend Growth
  * Competition Level
  * Monetization Potential
* Automatically selects the highest-scoring topic.

## SEO Optimization

* Generates:

  * Primary Keyword
  * Secondary Keywords
  * Long-Tail Keywords
  * SEO Title
  * Meta Description
  * URL Slug
  * Open Graph Metadata
  * Twitter Metadata

## Blog Generation

* Creates complete articles using Gemini AI.
* AdSense-friendly content.
* Human-readable structure.
* EEAT-oriented writing.
* FAQ generation.
* Internal linking suggestions.

## Image Generation Support

* Creates prompts for:

  * Featured Image
  * Supporting Images
* Generates:

  * Alt Text
  * Captions
  * Image Placement Recommendations

## Publishing

* Stores generated content in Firestore.
* Supports publishing to:

  * WordPress
  * Custom CMS
  * REST APIs

---

# Tech Stack

## Frontend

* Flutter
* Dart

## Backend Services

* Firebase Authentication
* Cloud Firestore

## AI Services

* Google Gemini API

## Search & Trend Discovery

* Tavily Search API

## Networking

* Dio

## State Management

* Provider

## Environment Management

* flutter_dotenv

---

# Project Architecture

```text
Flutter App
    │
    ▼
Blog Writer Agent
    │
    ├── Tavily Search API
    │       ├── Trending Topics
    │       ├── Search Research
    │       └── Competitor Analysis
    │
    ▼
Gemini API
    │
    ├── Topic Evaluation
    ├── SEO Research
    ├── Content Generation
    ├── Metadata Generation
    └── Image Prompt Generation
    │
    ▼
Firestore
    │
    ▼
Website Publishing API
```

---

# Environment Variables

Create a `.env` file in the project root.

```env
# Google Gemini API Key
GEMINI_API_KEY=YOUR_GEMINI_API_KEY

# Tavily Search API Key
TAVILY_API_KEY=YOUR_TAVILY_API_KEY

# WordPress Publishing
WORDPRESS_URL=https://your-wordpress-site.com/
WORDPRESS_USERNAME=your_username
WORDPRESS_APP_PASSWORD=your_app_password
```


# API Configuration

## Gemini API

Provider:
Google Gemini

Documentation:
https://ai.google.dev/

Purpose:

* Content Generation
* SEO Optimization
* Metadata Creation
* Image Prompt Creation

---

## Tavily API

Provider:
Tavily

Documentation:
https://docs.tavily.com/

Purpose:

* Trending Topic Discovery
* Search Research
* Competitor Analysis
* Current Web Information

---

# Blog Generation Workflow

## Step 1

Search Trending Topics

Input:

```text
Latest AI, technology, startup, and developer trends
```

Output:

```text
List of trending topics
```

---

## Step 2

Topic Scoring

Factors:

* Search Volume
* Trend Growth
* Competition
* Monetization

Output:

```text
Highest opportunity topic
```

---

## Step 3

SEO Research

Output:

* Primary Keyword
* Secondary Keywords
* Long-Tail Keywords
* Search Intent

---

## Step 4

Generate Blog Content

Output:

* SEO Title
* Full Article
* FAQ Section
* Internal Linking Suggestions

---

## Step 5

Generate Metadata

Output:

* Meta Title
* Meta Description
* Tags
* Categories
* Open Graph Data

---

## Step 6

Generate Image Package

Output:

* Featured Image Prompt
* Supporting Image Prompts
* Alt Text
* Captions

---

## Step 7

Publish

Output:

* Save to Firestore
* Publish to Website

---

# Folder Structure

```text
lib/
│
├── main.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── blog_writer_screen.dart
│   └── article_preview_screen.dart
│
├── services/
│   ├── gemini_service.dart
│   ├── tavily_service.dart
│   ├── firestore_service.dart
│   └── publishing_service.dart
│
├── providers/
│   └── blog_provider.dart
│
├── models/
│   ├── article_model.dart
│   └── topic_model.dart
│
├── data/
│   └── prompts.dart
│
└── widgets/
    └── reusable_widgets.dart
```

---

# Future Improvements

* Multi-language blog generation
* Scheduled publishing
* AI-generated images
* Keyword rank tracking
* Automatic internal linking
* Content update suggestions
* Social media post generation
* Newsletter generation
* Content clustering
* Analytics dashboard

---

# Author

AI Blog Writer Agent

Built using Flutter, Firebase, Gemini AI, and Tavily Search API.
