import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 28 * scale, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: onSettings,
          tooltip: 'Settings',
          icon: Icon(Icons.settings_outlined, size: 21 * scale),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(9 * scale),
          ),
        ),
      ],
    );
  }
}

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.accountId,
    required this.serviceProvider,
    required this.faceIdStatus,
  });

  final String name;
  final String email;
  final String phoneNumber;
  final String accountId;
  final String serviceProvider;
  final String faceIdStatus;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 76 * scale,
              height: 76 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E3E8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFB7B7BC),
                  width: 2 * scale,
                ),
              ),
              child: Icon(
                Icons.person,
                color: Color(0xFF8D8E94),
                size: 49 * scale,
              ),
            ),
            Container(
              width: 23 * scale,
              height: 23 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFFE6001A),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 14 * scale),
            ),
          ],
        ),
        SizedBox(height: 9 * scale),
        Text(
          name,
          style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4 * scale),
        Text(
          '$email · $phoneNumber',
          style: TextStyle(
            color: const Color(0xFF8C8D93),
            fontSize: 11 * scale,
          ),
        ),
        SizedBox(height: 10 * scale),
        Wrap(
          spacing: 7 * scale,
          children: [
            _ProfileBadge(
              label: accountId,
              color: const Color(0xFF2EAF5D),
              backgroundColor: const Color(0xFFD9F3E1),
            ),
            _ProfileBadge(
              label: serviceProvider,
              color: const Color(0xFF8A8B91),
              backgroundColor: const Color(0xFFE7E7EA),
            ),
            _ProfileBadge(
              label: faceIdStatus,
              icon: Icons.face,
              color: const Color(0xFF2EAF5D),
              backgroundColor: const Color(0xFFD9F3E1),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 12 * scale,
        ),
        child: Row(
          children: [
            _TileIcon(icon: icon),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14 * scale)),
                  SizedBox(height: 3 * scale),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF8C8D93),
                      fontSize: 11 * scale,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Color(0xFFB5B6BB),
                size: 21 * scale,
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileAccountTile extends StatelessWidget {
  const ProfileAccountTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ProfileInfoTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 14 * scale,
        ),
        child: Row(
          children: [
            _TileIcon(icon: icon),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 14 * scale)),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFFB5B6BB),
              size: 21 * scale,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSignOutButton extends StatelessWidget {
  const ProfileSignOutButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE6001A),
          padding: EdgeInsets.symmetric(vertical: 14 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text('Sign Out', style: TextStyle(fontSize: 14 * scale)),
      ),
    );
  }
}

class ProfileSettingsHeader extends StatelessWidget {
  const ProfileSettingsHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back to profile',
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.w700),
          ),
        ),
        Text('Profile', style: TextStyle(fontSize: 13 * scale)),
      ],
    );
  }
}

class ProfileSettingSwitchTile extends StatelessWidget {
  const ProfileSettingSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        11 * scale,
        9 * scale,
        11 * scale,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14 * scale)),
                SizedBox(height: 4 * scale),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF8C8D93),
                    fontSize: 11 * scale,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return Container(
      width: 27 * scale,
      height: 27 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(7 * scale),
      ),
      child: Icon(icon, color: const Color(0xFF77787F), size: 17 * scale),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scale = _profileScale(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12 * scale),
            SizedBox(width: 3 * scale),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

double _profileScale(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return (width / 375).clamp(0.95, 1.25).toDouble();
}
