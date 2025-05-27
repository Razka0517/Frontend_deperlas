class Pelatih {
  final int id;
  final String nama;

  Pelatih({required this.id, required this.nama});

  factory Pelatih.fromJson(Map<String, dynamic> json) {
    return Pelatih(id: json['id'], nama: json['nama']);
  }
}
