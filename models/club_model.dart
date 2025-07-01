// Conceptual representation of a Club

enum ClubPrivacy {
  public, // Anyone can see and join
  private, // Requires approval to join, might be unlisted or visible with application
}

class Club {
  final String id; // Document ID from Firestore
  String name;
  String description;
  final String creatorUid; // UID of the user who created the club
  List<String> memberUids; // List of UIDs of club members
  List<String> adminUids; // List of UIDs of club admins (initially just the creator)
  ClubPrivacy privacy;
  String? imageUrl; // Optional URL for club's image/logo
  DateTime createdAt;
  DateTime updatedAt;
  // Potentially: List<String> tags;

  Club({
    required this.id,
    required this.name,
    this.description = '',
    required this.creatorUid,
    List<String>? memberUids,
    List<String>? adminUids,
    this.privacy = ClubPrivacy.public,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  })  : this.memberUids = memberUids ?? [creatorUid], // Creator is a member by default
        this.adminUids = adminUids ?? [creatorUid]; // Creator is an admin by default

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'creatorUid': creatorUid,
      'memberUids': memberUids,
      'adminUids': adminUids,
      'privacy': privacy.toString().split('.').last,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Club.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Club(
      id: documentId,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      creatorUid: data['creatorUid'] as String,
      memberUids: List<String>.from(data['memberUids'] as List<dynamic>? ?? []),
      adminUids: List<String>.from(data['adminUids'] as List<dynamic>? ?? []),
      privacy: ClubPrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == data['privacy'],
        orElse: () => ClubPrivacy.public,
      ),
      imageUrl: data['imageUrl'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}

/*
Firestore structure for 'clubs' collection:
/clubs/{auto_generated_id}
  - name: "Awesome Cycling Club"
  - description: "A club for awesome cyclists."
  - creatorUid: "uid_of_creator"
  - memberUids: ["uid_of_creator", "uid_of_member1", ...]
  - adminUids: ["uid_of_creator", ...]
  - privacy: "public" | "private"
  - imageUrl: "url_to_image" (optional)
  - createdAt: Timestamp
  - updatedAt: Timestamp
*/
namespace models {} // To satisfy the linter for package_rename
