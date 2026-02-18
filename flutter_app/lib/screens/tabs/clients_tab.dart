import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/client_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/client_detail_screen.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_overlay.dart';

class ClientsTab extends StatefulWidget {
  const ClientsTab({super.key});

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  final _api = ApiService();
  String _q = '';
  bool _busy = false;

  List<ClientModel> _filter(List<ClientModel> clients) {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return clients;
    return clients.where((c) {
      final hay = '${c.name} ${c.primaryEmail ?? ''} ${c.pan ?? ''} ${c.gstin ?? ''} ${c.cin ?? ''}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  Future<void> _openCreateClient() async {
    final name = TextEditingController();
    final pan = TextEditingController();
    final gstin = TextEditingController();
    final cin = TextEditingController();
    final ay = TextEditingController();
    final eng = TextEditingController();
    final email = TextEditingController();
    final cc = TextEditingController();
    final bcc = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Create Client', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18)),
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'Client name')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: pan, decoration: const InputDecoration(labelText: 'PAN'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: gstin, decoration: const InputDecoration(labelText: 'GSTIN'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: cin, decoration: const InputDecoration(labelText: 'CIN'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: ay, decoration: const InputDecoration(labelText: 'Assessment Year'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: eng, decoration: const InputDecoration(labelText: 'Engagement type')),
                  const SizedBox(height: 10),
                  TextField(controller: email, decoration: const InputDecoration(labelText: 'Primary email')),
                  const SizedBox(height: 10),
                  TextField(controller: cc, decoration: const InputDecoration(labelText: 'CC emails (;)')),
                  const SizedBox(height: 10),
                  TextField(controller: bcc, decoration: const InputDecoration(labelText: 'BCC emails (;)')),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              if (name.text.trim().isEmpty) {
                                Helpers.showSnackBar(context, 'Client name is required', isError: true);
                                return;
                              }
                              setState(() => _busy = true);
                              final res = await _api.createClient({
                                'name': name.text.trim(),
                                'pan': pan.text.trim(),
                                'gstin': gstin.text.trim(),
                                'cin': cin.text.trim(),
                                'assessmentYear': ay.text.trim(),
                                'engagementType': eng.text.trim(),
                                'primaryEmail': email.text.trim(),
                                'ccEmails': Helpers.parseEmailList(cc.text),
                                'bccEmails': Helpers.parseEmailList(bcc.text),
                              });
                              setState(() => _busy = false);
                              if (!mounted) return;
                              if (!res.ok) {
                                Helpers.showSnackBar(context, res.error ?? 'Create failed', isError: true);
                                return;
                              }
                              Helpers.showSnackBar(context, 'Client created', isSuccess: true);
                              Navigator.pop(ctx);
                            },
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();

    if (!auth.canAccessClients) {
      return const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Clients locked',
          subtitle: 'Clients are available to PARTNER role only.',
        ),
      );
    }

    return StreamBuilder<List<ClientModel>>(
      stream: app.clientsStream(),
      builder: (context, snap) {
        final all = snap.data ?? [];
        final list = _filter(all);

        return LoadingOverlay(
          isLoading: _busy,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              children: [
                GlassCard(
                  title: 'Clients',
                  subtitle: '${list.length} shown • ${all.length} total',
                  accentColor: AppTheme.viewAccents['clients'],
                  trailing: IconButton(
                    onPressed: _openCreateClient,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _q = v),
                        decoration: const InputDecoration(
                          hintText: 'Search clients (name, email, PAN, GSTIN)…',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (list.isEmpty)
                        const EmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No clients found',
                          subtitle: 'Try another search.',
                        )
                      else
                        Column(
                          children: list.take(500).map((c) {
                            return ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              tileColor: Theme.of(context).cardColor,
                              title: Text(c.name, style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
                              subtitle: Text(
                                '${c.primaryEmail ?? ""}${(c.gstin ?? "").isNotEmpty ? " • ${c.gstin}" : ""}${(c.pan ?? "").isNotEmpty ? " • ${c.pan}" : ""}',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: c.id)),
                                );
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
