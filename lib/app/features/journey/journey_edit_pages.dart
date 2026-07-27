import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/journey_editor_shared.dart';
import 'package:primeatlas/app/state/journey_state.dart';

class DirectionPage extends ConsumerStatefulWidget {
  const DirectionPage({super.key});

  @override
  ConsumerState<DirectionPage> createState() => _DirectionPageState();
}

class _DirectionPageState extends ConsumerState<DirectionPage> {
  late final TextEditingController directionController;
  late final TextEditingController constraintController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(journeyControllerProvider);
    directionController = TextEditingController(text: state.direction);
    constraintController = TextEditingController(text: state.constraint);
  }

  @override
  void dispose() {
    directionController.dispose();
    constraintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JourneyEditorScaffold(
      title: '表达方向',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('只记录你的目标、时间、场景和现实约束，不需要确认任何身份。'),
          const SizedBox(height: AppTokens.space5),
          TextField(
            controller: directionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '你想改善什么？',
              hintText: '写下你的原话',
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          TextField(
            controller: constraintController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '现实约束',
              hintText: '例如可用时间、场景或需要避开的安排',
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                if (directionController.text.trim().isEmpty ||
                    constraintController.text.trim().isEmpty) {
                  showJourneyEditorError(context, '请先补充方向和现实约束。');
                  return;
                }
                ref.read(journeyControllerProvider.notifier).saveDirection(
                      direction: directionController.text,
                      constraint: constraintController.text,
                    );
                context.pop();
              },
              child: const Text('保存方向草案'),
            ),
          ),
        ],
      ),
    );
  }
}

class MilestonePage extends ConsumerStatefulWidget {
  const MilestonePage({super.key});

  @override
  ConsumerState<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends ConsumerState<MilestonePage> {
  late final TextEditingController titleController;
  late final TextEditingController evidenceController;
  late final TextEditingController windowController;

  @override
  void initState() {
    super.initState();
    final milestone = ref.read(journeyControllerProvider).milestone;
    titleController = TextEditingController(text: milestone?.title);
    evidenceController = TextEditingController(text: milestone?.evidenceRule);
    windowController = TextEditingController(text: milestone?.window);
  }

  @override
  void dispose() {
    titleController.dispose();
    evidenceController.dispose();
    windowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JourneyEditorScaffold(
      title: '确认里程碑',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('每个里程碑都需要时间窗口、证据规则和完成说明。'),
          const SizedBox(height: AppTokens.space4),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: '里程碑'),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            controller: evidenceController,
            decoration: const InputDecoration(labelText: '证据规则'),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            controller: windowController,
            decoration: const InputDecoration(labelText: '时间窗口'),
          ),
          const SizedBox(height: AppTokens.space5),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    evidenceController.text.trim().isEmpty ||
                    windowController.text.trim().isEmpty) {
                  showJourneyEditorError(context, '请补充里程碑的三个必要字段。');
                  return;
                }
                ref.read(journeyControllerProvider.notifier).saveMilestone(
                      MilestoneDraft(
                        title: titleController.text.trim(),
                        evidenceRule: evidenceController.text.trim(),
                        window: windowController.text.trim(),
                      ),
                    );
                context.pop();
              },
              child: const Text('保存里程碑'),
            ),
          ),
        ],
      ),
    );
  }
}
