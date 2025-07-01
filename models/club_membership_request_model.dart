// Conceptual representation of a Club Membership Request (for private clubs)

enum MembershipRequestStatus {
  pending,
  approved,
  declined,
}

class ClubMembershipRequest {
  final String id; // Document ID from Firestore
  final String userId; // UID of the user requesting to join
  final String clubId; // ID of the club they want to join
  MembershipRequestStatus status;
  final DateTime requestedAt;
  DateTime? resolvedAt; // Timestamp when an admin approved/declined

  ClubMembershipRequest({
    required this.id,
    required this.userId,
    required this.clubId,
    this.status = MembershipRequestStatus.pending,
    required this.requestedAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'clubId': clubId,
      'status': status.toString().split('.').last,
      'requestedAt': requestedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory ClubMembershipRequest.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ClubMembershipRequest(
      id: documentId,
      userId: data['userId'] as String,
      clubId: data['clubId'] as String,
      status: MembershipRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => MembershipRequestStatus.pending,
      ),
      requestedAt: DateTime.parse(data['requestedAt'] as String),
      resolvedAt: data['resolvedAt'] != null ? DateTime.parse(data['resolvedAt'] as String) : null,
    );
  }
}

/*
Firestore structure for 'clubMembershipRequests' collection:
/clubMembershipRequests/{auto_generated_id}
  - userId: "uid_of_user_requesting"
  - clubId: "id_of_the_private_club"
  - status: "pending" | "approved" | "declined"
  - requestedAt: Timestamp
  - resolvedAt: Timestamp (optional, set when status changes from pending)
*/
namespace models {} // To satisfy the linter for package_rename
