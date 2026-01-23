import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/project_data_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    // Edit Button
                    _ActionButton(
                      icon: Icons.edit,
                      color: context.theme.colorScheme.secondary,
                      onPressed: () => _handleEdit(context),
                    ),
                    const SizedBox(width: 12),
                    // Add Trees Button
                    _ActionButton(
                      icon: Icons.add_circle,
                      color: context.theme.colorScheme.tertiary,
                      onPressed: () => _handleAddTrees(context),
                    ),
                    const SizedBox(width: 12),
                    // Download Button
                    _ActionButton(
                      icon: Icons.download,
                      color: context.theme.colorScheme.primary,
                      onPressed: () => _handleDownload(context),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Project Details
            _ProjectDetailRow(
              icon: Icons.location_on,
              title: 'Location',
              value: '${project.state}, ${project.district}',
              context: context,
            ),

            const SizedBox(height: 12),

            _ProjectDetailRow(
              icon: Icons.park,
              title: 'Trees Planted',
              value: '${project.treesCount}',
              isHighlighted: true,
              context: context,
            ),

            const SizedBox(height: 12),

            _ProjectDetailRow(
              icon: Icons.calendar_today,
              title: 'Project Duration',
              value:
                  '${_formatDate(project.startDate)} - ${_formatDate(project.endDate)}',
              context: context,
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(_calculateProgress(project) * 100).toStringAsFixed(1)}% Complete',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Progress Indicator
            LinearProgressIndicator(
              value: _calculateProgress(project),
              backgroundColor: context.theme.colorScheme.surfaceVariant
                  .withValues(alpha: 0.3),
              color: context.theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),



            // Progress Text

          ],
        ),
      ),
    );
  }

  double _calculateProgress(Project project) {
    final totalDuration = project.endDate.difference(project.startDate).inDays;
    final elapsedDuration = DateTime.now().difference(project.startDate).inDays;
    final progress = elapsedDuration / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleEdit(BuildContext context) {
    // Handle edit action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${project.name}'),
        backgroundColor: context.theme.colorScheme.secondary,
      ),
    );
  }

  void _handleAddTrees(BuildContext context) {
    // Handle add trees action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add trees to ${project.name}'),
        backgroundColor: context.theme.colorScheme.tertiary,
      ),
    );
  }

  void _handleDownload(BuildContext context) {
    // Handle download action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download ${project.name} report'),
        backgroundColor: context.theme.colorScheme.primary,
      ),
    );
  }
}

class _ProjectDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isHighlighted;
  final BuildContext context;

  const _ProjectDetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isHighlighted = false,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        style: IconButton.styleFrom(side: BorderSide.none),
        onPressed: onPressed,
        splashRadius: 20,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
