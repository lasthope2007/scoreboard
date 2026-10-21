import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../localization/app_localizations.dart';
import '../models/enums.dart';
import '../models/match_record.dart';
import '../state/history_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogs.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    final l = context.l10n;
    final items = history.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('history')),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: l.t('delete_all'),
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                if (await confirmDialog(
                  context,
                  l.t('confirm_delete_all'),
                  confirmLabel: l.t('delete_all'),
                )) {
                  history.clear();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Text(
                  l.t('history_empty'),
                  style: const TextStyle(fontSize: 18),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  mainAxisExtent: 148,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, i) => _RecordTile(
                  record: items[i],
                  onDelete: () async {
                    if (await confirmDialog(
                      context,
                      l.t('confirm_delete'),
                      confirmLabel: l.t('delete'),
                    )) {
                      history.remove(items[i].id);
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onDelete});

  final MatchRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.65);

    Widget side(String name, int score, Side s) {
      final won = record.winner == s;
      return Expanded(
        child: Column(
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: won ? FontWeight.w900 : FontWeight.w500,
                color: AppColors.side(s),
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: won ? FontWeight.w900 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    side(record.redName, record.redScore, Side.red),
                    Text(l.t('vs'), style: TextStyle(color: muted)),
                    side(record.blueName, record.blueScore, Side.blue),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${l.t('winner')}: ${record.winnerName} · ${l.reasonLabel(record.reason)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '${formatDateTime(record.dateTime)}  ·  ${formatSeconds(record.durationSeconds)}',
                    style: TextStyle(fontSize: 13, color: muted),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.t('delete'),
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
