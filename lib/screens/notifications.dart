import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 11, 32, 11),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              SizedBox(height: 20);

              return Card(
                color: Color.fromARGB(255, 223, 236, 223),
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding:
                      const EdgeInsets.all(12.0), // Padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'No Title',
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8), // Space between title and body
                      Text(
                        notification['body'] ?? 'No Content',
                        style: TextStyle(
                          color: Color.fromARGB(195, 6, 135, 27),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                          height: 10), // Space between body and bottom section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (notification['timestamp'] as Timestamp)
                                .toDate()
                                .toString(),
                            style: TextStyle(
                              color: Color.fromARGB(255, 202, 169, 21),
                              fontSize: 12,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(context, notification.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to show a confirmation dialog before deleting
  void _showDeleteConfirmation(BuildContext context, String notificationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Notification"),
          content: Text("Are you sure you want to delete this notification?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteNotification(
                    notificationId); // Call the function to delete
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a notification from Firestore
  Future<void> _deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete()
        .then((_) {
      print("Notification deleted successfully!");
    }).catchError((error) {
      print("Failed to delete notification: $error");
    });
  }
}
