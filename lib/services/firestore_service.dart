import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/article_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _userArticles {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _db.collection('users').doc(uid).collection('articles');
  }

  /// Save a new article to Firestore
  Future<String> saveArticle(Article article) async {
    final docRef = await _userArticles.add(article.toFirestore());
    return docRef.id;
  }

  /// Update publish status
  Future<void> updatePublishStatus(
      String id, PublishStatus status, {String? wordpressPostId}) async {
    await _userArticles.doc(id).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
      if (wordpressPostId != null) 'wordpressPostId': wordpressPostId,
    });
  }

  /// Stream list of all articles ordered by createdAt
  Stream<List<Article>> getArticles() {
    if (_auth.currentUser == null) return const Stream.empty();
    return _userArticles
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Article.fromFirestore(
                doc.data(), doc.id))
            .toList());
  }

  /// Get a single article by ID
  Future<Article?> getArticleById(String id) async {
    final doc = await _userArticles.doc(id).get();
    if (!doc.exists) return null;
    return Article.fromFirestore(doc.data()!, doc.id);
  }

  /// Delete an article
  Future<void> deleteArticle(String id) async {
    await _userArticles.doc(id).delete();
  }
}
