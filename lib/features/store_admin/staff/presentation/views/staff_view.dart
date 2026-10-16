import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/shell/data/models/branch.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_scaffold.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_sidebar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/pagination_bar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/side_panel_frame.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/staff_table.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/worker_card.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/worker_detail_panel.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/worker_form.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/worker_labels.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/view_models/staff_filter_view_model.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/view_models/staff_view_model.dart';

/// Staff tab: packers of the selected branch and all drivers.
/// The admin can add, edit and deactivate workers.
class StaffView extends ConsumerStatefulWidget {
  const StaffView({super.key});

  @override
  ConsumerState<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends ConsumerState<StaffView> {
  /// Page widths where the layout changes.
  static const double _tableWidth = 720;
  static const double _sidePanelWidth = 1000;

  final _searchController = TextEditingController();

  /// Worker open in the side panel.
  String? _selectedWorkerId;

  /// True if the side panel shows the add form.
  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _closePanel() {
    setState(() {
      _selectedWorkerId = null;
      _isAdding = false;
    });
  }

  /// Opens a worker in the side panel, or as a full page if no room.
  void _openWorker(Worker worker, {required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() {
        _selectedWorkerId = worker.id;
        _isAdding = false;
      });
      return;
    }

    _pushPage(
      (pageContext) => WorkerDetailPanel(
        workerId: worker.id,
        onClose: () => Navigator.of(pageContext).pop(),
      ),
    );
  }

  /// Opens the add form in the side panel, or as a full page if no room.
  void _openAddForm({required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() {
        _selectedWorkerId = null;
        _isAdding = true;
      });
      return;
    }

    _pushPage(
      (pageContext) => _AddWorkerPanel(
        onClose: () => Navigator.of(pageContext).pop(),
        onAdded: (name) {
          Navigator.of(pageContext).pop();
          _showMessage('$name was added.');
        },
      ),
    );
  }

  void _pushPage(WidgetBuilder panelBuilder) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) =>
            Scaffold(body: SafeArea(child: panelBuilder(pageContext))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final staff = ref.watch(staffViewModelProvider);
    final filter = ref.watch(staffFilterViewModelProvider);
    final filterViewModel = ref.read(staffFilterViewModelProvider.notifier);
    final branchState = ref.watch(branchViewModelProvider).value;
    final branches = branchState?.branches ?? const <Branch>[];

    return AdminScaffold(
      currentPage: AdminPage.staff,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Width of the page without the sidebar.
          final showTable = constraints.maxWidth >= _tableWidth;
          final hasRoomForPanel = constraints.maxWidth >= _sidePanelWidth;
          final showPanel =
              hasRoomForPanel && (_isAdding || _selectedWorkerId != null);

          final page = Padding(
            padding: EdgeInsets.all(showTable ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  branchName: branchState?.selected.name,
                  isWide: showTable,
                  searchController: _searchController,
                  onSearchChanged: filterViewModel.setSearchText,
                  onAddWorker: () {
                    _openAddForm(inSidePanel: hasRoomForPanel);
                  },
                ),
                SizedBox(height: showTable ? 24 : 12),
                Expanded(
                  child: staff.when(
                    // Keep the old list on screen while reloading.
                    skipLoadingOnReload: true,
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Could not load the staff.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    data: (result) {
                      final shown = result.items;

                      if (shown.isEmpty) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            filter.searchText.trim().isEmpty
                                ? 'No workers yet. Add the first one.'
                                : 'No workers match your search.',
                            style: textTheme.bodyMedium,
                          ),
                        );
                      }

                      final Widget list;
                      if (!showTable) {
                        list = ListView.separated(
                          itemCount: shown.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final worker = shown[index];
                            return WorkerCard(
                              worker: worker,
                              branchName: workerBranchName(worker, branches),
                              onTap: () {
                                _openWorker(worker, inSidePanel: false);
                              },
                            );
                          },
                        );
                      } else {
                        list = StaffTable(
                          workers: shown,
                          branches: branches,
                          selectedWorkerId: showPanel
                              ? _selectedWorkerId
                              : null,
                          onWorkerTap: (worker) {
                            _openWorker(worker, inSidePanel: hasRoomForPanel);
                          },
                        );
                      }

                      return Column(
                        children: [
                          // The key puts a new page back at the top.
                          Expanded(
                            child: KeyedSubtree(
                              key: ValueKey(result.page),
                              child: list,
                            ),
                          ),
                          const SizedBox(height: 8),
                          PaginationBar(
                            result: result,
                            itemName: 'workers',
                            onPageChanged: (page) {
                              _closePanel();
                              filterViewModel.setPage(page);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );

          if (!showPanel) return page;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: page),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 380,
                child: _isAdding
                    ? _AddWorkerPanel(
                        onClose: _closePanel,
                        onAdded: (name) {
                          _closePanel();
                          _showMessage('$name was added.');
                        },
                      )
                    // The key resets the panel when another worker is opened.
                    : WorkerDetailPanel(
                        key: ValueKey(_selectedWorkerId),
                        workerId: _selectedWorkerId!,
                        onClose: _closePanel,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The add form inside the side panel.
class _AddWorkerPanel extends StatelessWidget {
  const _AddWorkerPanel({required this.onClose, required this.onAdded});

  final VoidCallback onClose;

  /// Called with the new worker's name.
  final ValueChanged<String> onAdded;

  @override
  Widget build(BuildContext context) {
    return SidePanelFrame(
      title: 'Add worker',
      onClose: onClose,
      child: WorkerForm(onCancel: onClose, onSaved: onAdded),
    );
  }
}

/// Title, search box and "Add worker" button.
/// No title on phones (the app bar shows it).
class _Header extends StatelessWidget {
  const _Header({
    required this.branchName,
    required this.isWide,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddWorker,
  });

  final String? branchName;
  final bool isWide;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddWorker;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final search = TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search staff',
        prefixIcon: Icon(Icons.search_rounded),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    );

    final addButton = FilledButton.icon(
      onPressed: onAddWorker,
      // Theme buttons are full width; this one fits its label.
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text(isWide ? 'Add worker' : 'Add'),
    );

    if (!isWide) {
      return Row(
        children: [
          Expanded(child: search),
          const SizedBox(width: 8),
          addButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Staff', style: textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                branchName == null
                    ? 'Packing staff and delivery drivers'
                    : 'Packing staff at $branchName · all delivery drivers',
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 280, child: search),
        const SizedBox(width: 12),
        addButton,
      ],
    );
  }
}
