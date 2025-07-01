// Conceptual representation of a Friend Request

// Possible statuses for a friend request
enum FriendRequestStatus {
  pending,
  accepted,
  declined,
  blocked // Could also be handled by the blockedUserUids list in UserProfile
}

class FriendRequest {
  final String id; // Document ID from Firestore
  final String fromUserId;
  final String toUserId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status.toString().split('.').last, // Store enum as string e.g. "pending"
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FriendRequest.fromFirestore(Map<String, dynamic> data, String documentId) {
    return FriendRequest(
      id: documentId,
      fromUserId: data['fromUserId'] as String,
      toUserId: data['toUserId'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => FriendRequestStatus.pending, // Default if status is missing or invalid
      ),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}

/*
Firestore structure for 'friendRequests' collection:
/friendRequests/{auto_generated_id}
  - fromUserId: "uid_of_sender"
  - toUserId: "uid_of_receiver"
  - status: "pending" | "accepted" | "declined"
  - createdAt: Timestamp
  - updatedAt: Timestamp
*/
namespace models {} // To satisfy the linter for package_rename
