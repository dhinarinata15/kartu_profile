class ProfileData {
  final String name;
  final String title;
  final String bio;

  const ProfileData({
    required this.name,
    required this.title,
    required this.bio,
  });

  static const defaults = ProfileData(
    name: 'Dhina Rinata Suyitno',
    title: 'Mahasiswa',
    bio: 'Suka scroll dimana saja',
  );
}
