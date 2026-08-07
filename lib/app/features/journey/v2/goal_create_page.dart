import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_tokens.dart';
import 'package:primeatlas/app/features/journey/v2/journey_providers.dart';
import 'package:primeatlas/app/features/journey/v2/journey_strings.dart';
import 'package:primeatlas/app/state/app_providers.dart';
import 'package:primeatlas/application/goals/create_goal_candidate.dart';

class GoalCreatePage extends ConsumerStatefulWidget {
  const GoalCreatePage({this.presetDomainId, super.key});

  final String? presetDomainId;

  @override
  ConsumerState<GoalCreatePage> createState() => _GoalCreatePageState();
}

class _GoalCreatePageState extends ConsumerState<GoalCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gapController = TextEditingController();
  String? _domainId;
  DateTime? _targetDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _domainId = widget.presetDomainId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _gapController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_domainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一个成长域')),
      );
      return;
    }
    final ownerId = ref.read(ownerIdProvider);
    final note = _gapController.text.trim();
    final command = CreateGoalCandidateCommand(
      ownerId: ownerId,
      domainId: _domainId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      identityGap: note.isEmpty ? const {} : {'note': note},
      dataSufficiency: 'self_reported',
      sourceType: 'user_declared',
      targetAtUs: _targetDate?.microsecondsSinceEpoch,
    );

    setState(() => _submitting = true);
    await ref.read(goalActionsProvider.notifier).createDraft(command);
    final error = ref.read(goalActionsProvider).error;
    setState(() => _submitting = false);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.details['message'] as String? ?? '创建失败，请重试'),
        ),
      );
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final domainsAsync = ref.watch(activeDomainsProvider);
    final actions = ref.watch(goalActionsProvider);

    ref.listen<GoalActionState>(goalActionsProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.details['message'] as String? ?? '创建失败'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('新建目标')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tablet = constraints.maxWidth > 600;
          final form = Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '目标标题'),
                  maxLength: 80,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '请填写目标标题' : null,
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '目标描述（可选）'),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: AppTokens.space3),
                domainsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('成长域加载失败，无法选择'),
                  data: (domains) {
                    if (domains.isEmpty) {
                      return const Text('当前没有可用成长域，请先激活一个');
                    }
                    return DropdownButtonFormField<String>(
                      value: _domainId,
                      decoration: const InputDecoration(labelText: '所属成长域'),
                      items: domains
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(domainLabel(d.domainCode)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) => setState(() => _domainId = v),
                      validator: (v) => v == null ? '请选择成长域' : null,
                    );
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _targetDate == null
                        ? '未设置目标日期'
                        : DateTime.fromMicrosecondsSinceEpoch(
                            _targetDate!.microsecondsSinceEpoch,
                          ).toLocal().toString().split(' ').first,
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickTargetDate,
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _gapController,
                  decoration: const InputDecoration(
                    labelText: '身份差距笔记（可选）',
                    hintText: '写下这个目标想弥合的自我与现实之间的差距',
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: AppTokens.space6),
                FilledButton(
                  onPressed: _submitting || actions.busy ? null : _submit,
                  child: _submitting
                      ? const Text('保存中…')
                      : const Text('创建为草案'),
                ),
              ],
            ),
          );
          if (tablet) {
            return ListView(
              padding: const EdgeInsets.all(AppTokens.space4),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: form,
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppTokens.space4),
            children: [form],
          );
        },
      ),
    );
  }
}
