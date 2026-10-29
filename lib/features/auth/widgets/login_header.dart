import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.38,
      child: Stack(
        children: [
          // Top branding row (Logo + App Name)
          Positioned(
            top: 16,
            left: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    'lib/core/assets/logo.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                const Text.rich(
                  TextSpan(
                    style: TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: 'BANTAI\n',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'Driver App',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right:
                -size.width * 0.12,
            bottom:
                -size.height *
                0.02,
            child: Transform.flip(
              flipX: true,
              child: Image.asset(
                'lib/core/assets/rider-icon.png',
                height:
                    size.height *
                    0.32,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
