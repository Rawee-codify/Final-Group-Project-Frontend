import 'package:cassava_healthy_finder/screens/CreatePostScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 11, 32, 11),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('community_posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts available."));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreatePostScreen()));
        },
        backgroundColor: const Color.fromARGB(255, 150, 158, 150),
        child: const Icon(Icons.add),
        tooltip: 'Ask Community',
      ),
    );
  }

  // Build each post card
  Widget _buildPostCard(QueryDocumentSnapshot post) {
    final postData = post.data() as Map<String, dynamic>;
    final user = FirebaseAuth.instance.currentUser;

    // Convert Firestore timestamp to DateTime
    Timestamp? timestamp = postData['timestamp']; // Allow nulls
    DateTime postDate;
    // Check if the timestamp exists before converting it
    if (timestamp != null) {
      postDate = timestamp.toDate();
    } else {
      // If there's no timestamp, fallback to the current date/time
      postDate = DateTime.now();
    }

    // Format the date
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(postDate);

    // Get the username from Firestore, fallback to "Anonymous"
    String username = postData['username'] ?? "Anonymous";

    return Card(
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.grey.shade100,
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 47, 92, 48),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: () {
                    _sharePost(postData);
                  },
                ),
                if (user != null && user.uid == postData['user_id'])
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _editPost(post.id, postData);
                    },
                  ),
                if (user != null && user.uid == postData['user_id'])
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDeletePost(post.id);
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              postData['description'],
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          _buildLikeDislikeSection(
              post.id, postData), // Like and dislike section
          const SizedBox(height: 10),
          _buildCommentsSection(post.id, postData),
        ],
      ),
    );
  }

  // Like and Dislike section
  Widget _buildLikeDislikeSection(
      String postId, Map<String, dynamic> postData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.green),
            onPressed: () {
              _updateLikes(postId, postData['likes'] ?? 0);
            },
          ),
          Text('${postData['likes'] ?? 0}',
              style: const TextStyle(color: Colors.black87)),
          IconButton(
            icon: const Icon(Icons.thumb_down_alt_outlined, color: Colors.red),
            onPressed: () {
              _updateDislikes(postId, postData['dislikes'] ?? 0);
            },
          ),
          Text('${postData['dislikes'] ?? 0}',
              style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // Update likes in Firestore
  Future<void> _updateLikes(String postId, int currentLikes) async {
    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .update({
      'likes': currentLikes + 1,
    });
  }

  // Update dislikes in Firestore
  Future<void> _updateDislikes(String postId, int currentDislikes) async {
    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .update({
      'dislikes': currentDislikes + 1,
    });
  }

  // Share post function
  void _sharePost(Map<String, dynamic> postData) {
    final postTitle = postData['title'] ?? '';
    final postDescription = postData['description'] ?? '';
    Share.share('Check out this post: $postTitle\n$postDescription');
  }

  // Edit post function
  void _editPost(String postId, Map<String, dynamic> postData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          postId: postId,
          postData: postData,
        ),
      ),
    );
  }

  // Confirm delete post
  void _confirmDeletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deletePost(postId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Delete post from Firestore
  Future<void> _deletePost(String postId) async {
    await FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post deleted successfully!')),
    );
  }

  // Comment section builder
  Widget _buildCommentsSection(String postId, Map<String, dynamic> postData) {
    return Column(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('community_posts')
              .doc(postId)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No comments yet."),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final comment =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(comment['comment']),
                  subtitle: Text(comment['username'] ?? "Anonymous"),
                  trailing: Text(DateFormat('dd MMM, HH:mm')
                      .format(comment['timestamp'].toDate())),
                );
              },
            );
          },
        ),
        _buildAddComment(postId),
      ],
    );
  }

  // Add comment builder
  Widget _buildAddComment(String postId) {
    final TextEditingController _commentController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(hintText: "Add a comment..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () async {
              if (_commentController.text.isNotEmpty && user != null) {
                // Fetch user details from Firestore
                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                String username = userDoc['name'] ?? 'Anonymous';

                // Add the comment to Firestore
                await FirebaseFirestore.instance
                    .collection('community_posts')
                    .doc(postId)
                    .collection('comments')
                    .add({
                  'comment': _commentController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                  'username': username, // Use the fetched username
                });

                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
