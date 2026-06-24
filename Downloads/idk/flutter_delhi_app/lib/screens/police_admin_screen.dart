import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/inlay_chip.dart';
import '../shared/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/police_stations_provider.dart';
import '../data/models/police_station.dart';

class PoliceAdminScreen extends ConsumerStatefulWidget {
  const PoliceAdminScreen({super.key});

  @override
  ConsumerState<PoliceAdminScreen> createState() => _PoliceAdminScreenState();
}

class _PoliceAdminScreenState extends ConsumerState<PoliceAdminScreen> {
  String _searchQuery = '';
  String _activeDistrict = 'All';


  @override
  Widget build(BuildContext context) {
    final asyncDistricts = ref.watch(policeDistrictsProvider);
    final asyncStations = _searchQuery.isEmpty 
      ? ref.watch(policeStationsProvider)
      : ref.watch(searchPoliceStationsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: context.ground,
      drawer: const AppDrawer(),
      appBar: const LalAppBar(title: 'Police Administration'),
      body: Column(
        children: [
          FadeSlide(
            delay: const Duration(milliseconds: 100),
            child: _buildSearchBar(context),
          ),
          FadeSlide(
            delay: const Duration(milliseconds: 150),
            child: _buildEmergencyPanel(context),
          ),
          const SizedBox(height: 12),
          FadeSlide(
            delay: const Duration(milliseconds: 200),
            child: asyncDistricts.when(
              data: (districts) => _buildDistrictFilters(context, ['All', ...districts]),
              loading: () => const SizedBox(height: 48),
              error: (_, __) => const SizedBox(height: 48),
            ),
          ),
          Expanded(
            child: asyncStations.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading stations', style: AppTextStyles.body(color: context.danger))),
              data: (stations) {
                final filteredStations = _activeDistrict == 'All'
                  ? stations
                  : stations.where((s) => s.district == _activeDistrict).toList();

                if (filteredStations.isEmpty) {
                  return Center(child: Text('No police stations found.', style: AppTextStyles.bodySec(color: context.textSec)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStations.length,
                  itemBuilder: (context, index) {
                    return FadeSlide(
                      delay: Duration(milliseconds: 300 + (index * 50)),
                      child: _buildStationCard(context, filteredStations[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search police stations...',
          hintStyle: AppTextStyles.bodySec(color: context.textSec),
          prefixIcon: Icon(Icons.search, size: 20, color: context.textSec),
          filled: true,
          fillColor: context.raised,
        ),
        style: AppTextStyles.body(color: context.textPri),
      ),
    );
  }

  Widget _buildDistrictFilters(BuildContext context, List<String> districts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: districts.map((district) {
          final isActive = district == _activeDistrict;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _activeDistrict = district),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? context.primary : context.raised,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? context.primary : context.border,
                  ),
                ),
                child: Text(
                  district,
                  style: AppTextStyles.bodySmall(
                    color: isActive ? context.sandGlow : context.textPri,
                  ).copyWith(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStationCard(BuildContext context, PoliceStation station) {
    final isCyber = station.name.toLowerCase().contains('cyber');
    final phoneDisplay = station.phone.isNotEmpty ? station.phone.first : 'N/A';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          context.push('/police_station_detail', extra: station);
        },
        child: PietraCard(
          accentColor: isCyber ? context.info : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Text(station.name, style: AppTextStyles.chatTitle(color: context.textPri)),
                ),
                InlayChip(
                  status: InlayStatus.live,
                  label: isCyber ? 'Cyber Cell' : 'Open 24x7',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(station.district, style: AppTextStyles.bodySmall(color: context.accentDim)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: context.textSec),
                const SizedBox(width: 4),
                Text(phoneDisplay, style: AppTextStyles.bodySmall(color: context.textSec)),
                const SizedBox(width: 16),
                Icon(Icons.directions, size: 14, color: context.info),
                const SizedBox(width: 4),
                Text('Get Directions', style: AppTextStyles.bodySmall(color: context.info)),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildEmergencyPanel(BuildContext context) {
    final numbers = [
      {'label': 'Police Control', 'num': '100', 'icon': Icons.local_police, 'color': Colors.red},
      {'label': 'National Emergency', 'num': '112', 'icon': Icons.emergency, 'color': Colors.orange},
      {'label': 'Women Helpline', 'num': '1091', 'icon': Icons.woman, 'color': Colors.pink},
      {'label': 'Cyber Crime', 'num': '1930', 'icon': Icons.security, 'color': Colors.blue},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, size: 14, color: context.danger),
              const SizedBox(width: 8),
              Text(
                'EMERGENCY SPEED DIALS',
                style: AppTextStyles.bodySmall(color: context.textSec).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: numbers.map((n) {
              final color = n['color'] as Color;
              return InkWell(
                onTap: () async {
                  final uri = Uri.parse('tel:${n['num']}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: PietraCard(
                  accentColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(n['icon'] as IconData, size: 16, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              n['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: context.textPri,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              n['num'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
