import 'package:flutter/material.dart';

import '../controllers/profile_controller.dart';
import '../widgets/profile_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.controller});

  final ProfileController? controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProfileController();
    _ownsController = widget.controller == null;
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ProfileHeader(onSettings: _openSettings),
                  const SizedBox(height: 8),
                  ProfileIdentityCard(
                    name: _controller.fullName,
                    email: _controller.email,
                    phoneNumber: _controller.phoneNumber,
                    accountId: _controller.accountId,
                    serviceProvider: _controller.serviceProvider,
                    faceIdStatus: _controller.faceIdStatus,
                  ),
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    children: [
                      ProfileInfoTile(
                        icon: Icons.campaign_outlined,
                        title: 'SOS broadcast',
                        subtitle: 'What responders hear first',
                        onTap: () {},
                      ),
                      ProfileInfoTile(
                        icon: Icons.person_outline,
                        title: 'Rider details',
                        subtitle: _controller.vehicleDetails,
                        onTap: () {},
                      ),
                      ProfileInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Emergency contacts',
                        subtitle: _controller.emergencyContact,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _SectionLabel('Sign-in methods'),
                  const SizedBox(height: 5),
                  ProfileSectionCard(
                    children: [
                      ProfileAccountTile(
                        icon: Icons.g_mobiledata_rounded,
                        title: 'Google',
                        subtitle: 'Not linked',
                        onTap: _controller.connectGoogle,
                      ),
                      ProfileAccountTile(
                        icon: Icons.apple,
                        title: 'Apple',
                        subtitle: 'Not linked',
                        onTap: _controller.connectApple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Linking a second method means you can still reach your\n'
                    'rider record if you lose your password or your phone.',
                    style: TextStyle(color: Color(0xFF8C8D93), fontSize: 9),
                  ),
                  const SizedBox(height: 11),
                  ProfileSectionCard(
                    children: [
                      ProfileActionTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit profile information',
                        onTap: _controller.editProfile,
                      ),
                      ProfileActionTile(
                        icon: Icons.face_retouching_natural,
                        title: 'Face sign-in',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProfileSignOutButton(onTap: _controller.signOut),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileSettingsPage(controller: _controller),
      ),
    );
  }
}

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Scaffold(
        backgroundColor: const Color(0xFFF5F5FA),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              ProfileSettingsHeader(onBack: Navigator.of(context).pop),
              const _SectionLabel('Hands-Free Audio'),
              const SizedBox(height: 6),
              ProfileSectionCard(
                children: [
                  const _VolumeSetting(),
                  ProfileSettingSwitchTile(
                    title: 'Announce responder ETA updates',
                    subtitle: 'Every 30 seconds while help is in route',
                    value: controller.announceResponderEta,
                    onChanged: controller.setAnnounceResponderEta,
                  ),
                  ProfileSettingSwitchTile(
                    title: 'Auto-connect Bluetooth headset',
                    subtitle: 'Cardo Freecom 4',
                    value: controller.autoConnectHeadset,
                    onChanged: controller.setAutoConnectHeadset,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _SectionLabel('Safety & Policy'),
              const SizedBox(height: 6),
              ProfileSectionCard(
                children: [
                  ProfileInfoTile(
                    icon: Icons.description_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your helmet data and footage',
                    onTap: () {},
                  ),
                  ProfileInfoTile(
                    icon: Icons.article_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Acceptable use of B.A.N.T.A.I. hardware and app',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 9),
              const Center(
                child: Text(
                  'B.A.N.T.A.I. Driver 2.4.1 · P1 firmware 2.4.1',
                  style: TextStyle(color: Color(0xFF9B9CA2), fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF97989E),
          fontSize: 9,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _VolumeSetting extends StatelessWidget {
  const _VolumeSetting();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(11, 10, 11, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Voice alert volume', style: TextStyle(fontSize: 12)),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.volume_down_outlined, size: 15, color: Colors.grey),
              SizedBox(width: 4),
              Expanded(
                child: Slider(
                  value: 0.28,
                  onChanged: null,
                  activeColor: Color(0xFFE6001A),
                ),
              ),
            ],
          ),
          Text(
            'Emergency announcements always override this level and your music.',
            style: TextStyle(color: Color(0xFF8C8D93), fontSize: 9),
          ),
        ],
      ),
    );
  }
}
