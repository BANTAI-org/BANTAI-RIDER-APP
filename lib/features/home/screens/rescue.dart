import 'package:flutter/material.dart';

import '../controllers/rescue_controller.dart';
import '../widgets/active_rescue_widget.dart';
import '../widgets/rescue_safe_widget.dart';

class RescuePage extends StatefulWidget {
  const RescuePage({super.key, this.controller});

  final RescueController? controller;

  @override
  State<RescuePage> createState() => _RescuePageState();
}

class _RescuePageState extends State<RescuePage> {
  late final RescueController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RescueController();
    _ownsController = widget.controller == null;
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) {
      _controller.dispose();
    }
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
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _RescueTitle(),
                  const SizedBox(height: 20),
                  _controller.isRescueActive
                      ? ActiveRescueWidget(controller: _controller)
                      : RescueSafeWidget(
                          onPreviewIncident: _controller.previewIncident,
                        ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RescueTitle extends StatelessWidget {
  const _RescueTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Rescue',
      style: TextStyle(
        color: Colors.black,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
