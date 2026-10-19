import 'package:flutter/material.dart';

class FoodiePage extends StatefulWidget {
  const FoodiePage({super.key});

  @override
  _FoodiePageState createState() => _FoodiePageState();
}

class _FoodiePageState extends State<FoodiePage> {
  final List<Map<String, dynamic>> _posts = [
    {
      'username': 'foodlover123',
      'profilePic': 'assets/user1.jpg',
      'location': 'New York, USA',
      'postText': 'Just tried this amazing spaghetti recipe! 🍝 #delicious #foodie',
      'postImage': 'assets/spaghetti.jpg',
      'likes': 120,
      'comments': 15,
      'likedByUser': false,
    },
    {
      'username': 'chefjohn',
      'profilePic': 'assets/user2.jpg',
      'location': 'Paris, France',
      'postText': 'Made a classic French croissant today! 🥐 #baking #frenchpastry',
      'postImage': 'assets/croissant.jpg',
      'likes': 200,
      'comments': 30,
      'likedByUser': false,
    },
  ];

  void _createNewPost() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String postText = '';

        return AlertDialog(
          title: const Text('Create New Post'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'What\'s on your mind?'),
            onChanged: (value) {
              postText = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () {
                setState(() {
                  _posts.insert(0, {
                    'username': 'current_user',
                    'profilePic': 'assets/current_user.jpg',
                    'location': 'Your Location',
                    'postText': postText,
                    'postImage': null,
                    'likes': 0,
                    'comments': 0,
                    'likedByUser': false,
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _likePost(int index) {
    setState(() {
      _posts[index]['likedByUser'] = !_posts[index]['likedByUser'];
      _posts[index]['likes'] += _posts[index]['likedByUser'] ? 1 : -1;
    });
  }

  void _commentOnPost(int index) {
    // Implement comment functionality
  }

  void _sharePost(int index) {
    // Implement share functionality
  }

  void _showPostDetails(int index) {
    var post = _posts[index];
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: post['profilePic'] != null ? AssetImage(post['profilePic']) : null,
              ),
              title: Text(post['username']),
              subtitle: Text(post['location']),
            ),
            if (post['postImage'] != null)
              Image.asset(post['postImage']),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(post['postText'] ?? ''),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(post['likedByUser'] ? Icons.thumb_up : Icons.thumb_up_outlined),
                  label: Text('${post['likes']}'),
                  onPressed: () => _likePost(index),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: Text('${post['comments']}'),
                  onPressed: () => _commentOnPost(index),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () => _sharePost(index),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          var post = _posts[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () => _showPostDetails(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: post['profilePic'] != null ? AssetImage(post['profilePic']) : null,
                    ),
                    title: Text(post['username']),
                    subtitle: Text(post['location']),
                  ),
                  if (post['postImage'] != null)
                    Image.asset(post['postImage']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(post['postText'] ?? ''),
                  ),
                  OverflowBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton.icon(
                        icon: Icon(post['likedByUser'] ? Icons.thumb_up : Icons.thumb_up_outlined),
                        label: Text('${post['likes']}'),
                        onPressed: () => _likePost(index),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.comment),
                        label: Text('${post['comments']}'),
                        onPressed: () => _commentOnPost(index),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        onPressed: () => _sharePost(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPost,
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}