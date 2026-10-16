import 'package:flutter/material.dart';

import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_report.dart';

/// Table heading. Uses the same columns as [TopProductRow].
class TopProductsHeading extends StatelessWidget {
  const TopProductsHeading({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: _RowLayout(
        rank: Text('#', style: style),
        product: Text('PRODUCT', style: style),
        category: Text('CATEGORY', style: style),
        quantity: Text('SOLD', style: style, textAlign: TextAlign.end),
        revenue: Text('REVENUE', style: style, textAlign: TextAlign.end),
      ),
    );
  }
}

/// One widget per column, so the heading and rows line up.
class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.rank,
    required this.product,
    required this.category,
    required this.quantity,
    required this.revenue,
  });

  final Widget rank;
  final Widget product;
  final Widget category;
  final Widget quantity;
  final Widget revenue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(width: 44, child: rank),
          Expanded(flex: 4, child: product),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: category),
          SizedBox(width: 72, child: quantity),
          SizedBox(width: 120, child: revenue),
        ],
      ),
    );
  }
}

/// One product in the table. [rank] counts from 1 over all pages.
class TopProductRow extends StatelessWidget {
  const TopProductRow({required this.rank, required this.product, super.key});

  final int rank;
  final ProductSales product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _RowLayout(
        rank: Text('$rank', style: textTheme.bodyMedium),
        product: Text(
          product.name,
          style: textTheme.titleMedium?.copyWith(fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        category: Text(
          product.categoryName,
          style: textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        quantity: Text(
          '${product.quantity}',
          style: textTheme.bodyMedium,
          textAlign: TextAlign.end,
        ),
        revenue: Text(
          Formatters.money(product.revenue),
          style: textTheme.bodyMedium,
          textAlign: TextAlign.end,
        ),
      ),
    );
  }
}

/// One product as a list tile, for phones.
class TopProductTile extends StatelessWidget {
  const TopProductTile({required this.rank, required this.product, super.key});

  final int rank;
  final ProductSales product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Text('$rank', style: textTheme.titleMedium),
      minLeadingWidth: 24,
      title: Text(product.name, overflow: TextOverflow.ellipsis),
      subtitle: Text('${product.categoryName} · ${product.quantity} sold'),
      trailing: Text(
        Formatters.money(product.revenue),
        style: textTheme.titleMedium?.copyWith(fontSize: 15),
      ),
    );
  }
}
