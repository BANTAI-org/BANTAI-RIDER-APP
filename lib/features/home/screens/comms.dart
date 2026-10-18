import 'package:flutter/material.dart';

import '../controllers/comms_controller.dart';
import '../widgets/comms_chat_panel.dart';
import '../widgets/comms_header.dart';
import '../widgets/comms_map_panel.dart';
import '../widgets/comms_mode_switcher.dart';

class CommsPage extends StatefulWidget {
  const CommsPage({super.key, this.controller});

  final CommsController? controller;

  @override
  State<CommsPage> createState() => _CommsPageState();
}

class _CommsPageState extends State<CommsPage> {
  late final CommsController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CommsController();
    _ownsController = widget.controller == null;
    _controller.addListener(_refresh);
    _controller.initialize();
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
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const CommsHeader(),
                  const SizedBox(height: 18),
                  CommsModeSwitcher(
                    mode: _controller.mode,
                    onModeSelected: _controller.selectMode,
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _controller.mode == CommsMode.nearbyMap
                        ? CommsMapPanel(
                            key: const ValueKey(CommsMode.nearbyMap),
                            controller: _controller,
                          )
                        : const CommsChatPanel(
                            key: ValueKey(CommsMode.radioChat),
                          ),
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
