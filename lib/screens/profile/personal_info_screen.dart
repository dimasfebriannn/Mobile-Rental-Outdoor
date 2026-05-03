import 'package:flutter/material.dart';
import 'package:majelis_adventure/models/app_state.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final Color darkBrown = const Color(0xFF3E2723);
    final Color goldenYellow = const Color(0xFFE5A93D);
    final Color creamBg = const Color(0xFFF5EFE6);
    final Color deepBlack = const Color(0xFF1B1210);
    final Color softYellow = const Color.fromRGBO(229, 169, 61, 0.12);
    final Color softShadow = const Color.fromRGBO(62, 39, 35, 0.08);

    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: creamBg,
        elevation: 0,
        foregroundColor: darkBrown,
        title: const Text('Informasi Pribadi'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final profile = appState.profile;
          return Stack(
            children: [
              Positioned(
                top: -60,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: softYellow,
                  ),
                ),
              ),
              Positioned(
                top: 120,
                right: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: softShadow,
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: softShadow,
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: goldenYellow,
                                    width: 2,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  radius: 38,
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage(
                                    'lib/assets/img/majelis.png',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: TextStyle(
                                        color: darkBrown,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: goldenYellow,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          profile.memberStatus,
                                          style: TextStyle(
                                            color: deepBlack,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Perbarui data agar proses sewa semakin cepat dan terpercaya.',
                                      style: TextStyle(
                                        color: const Color.fromRGBO(
                                          62,
                                          39,
                                          35,
                                          0.72,
                                        ),
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Detail Akun',
                          style: TextStyle(
                            color: deepBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _infoField(
                          'Nama Lengkap',
                          profile.name,
                          darkBrown,
                          goldenYellow,
                        ),
                        _infoField(
                          'Email',
                          profile.email,
                          darkBrown,
                          goldenYellow,
                          enabled: false,
                        ),
                        _infoField(
                          'Nomor Telepon',
                          profile.phone,
                          darkBrown,
                          goldenYellow,
                        ),
                        _infoField(
                          'Alamat',
                          profile.address,
                          darkBrown,
                          goldenYellow,
                        ),
                        _infoField(
                          'Tanggal Lahir',
                          profile.birthdate,
                          darkBrown,
                          goldenYellow,
                          enabled: false,
                        ),
                        _infoField(
                          'Status Keanggotaan',
                          profile.memberStatus,
                          darkBrown,
                          goldenYellow,
                          enabled: false,
                        ),
                        _infoField(
                          'Terdaftar Sejak',
                          profile.memberSince,
                          darkBrown,
                          goldenYellow,
                          enabled: false,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Informasi Tambahan',
                          style: TextStyle(
                            color: deepBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _infoField(
                          'Nomor KTP',
                          profile.ktp,
                          darkBrown,
                          goldenYellow,
                        ),
                        _infoField(
                          'Jenis Kelamin',
                          profile.gender,
                          darkBrown,
                          goldenYellow,
                          enabled: false,
                        ),
                        _infoField(
                          'Pekerjaan',
                          profile.job,
                          darkBrown,
                          goldenYellow,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Informasi pribadi hanya untuk ditampilkan.',
                            style: TextStyle(
                              color: const Color.fromRGBO(62, 39, 35, 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoField(
    String label,
    String value,
    Color db,
    Color gy, {
    bool enabled = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color.fromRGBO(229, 169, 61, 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(62, 39, 35, 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromRGBO(62, 39, 35, 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: value,
            enabled: false,
            style: TextStyle(
              color: db,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF4EEE5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(229, 169, 61, 0.14),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(229, 169, 61, 0.14),
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(228, 225, 216, 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(229, 169, 61, 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.info_outline, color: gy, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
