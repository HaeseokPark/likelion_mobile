import 'package:flutter/material.dart';
import 'package:likelion/detail.dart';
import 'package:likelion/model/products_repository.dart';
import 'package:likelion/model/promise';
import 'package:likelion/widgets/global_bottombar.dart';
import 'package:likelion/widgets/sort_filter.dart';
import 'widgets/global_appbar.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key, required this.promise});

  final Promise promise;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 18 / 11,
      child: Image.asset(promise.imagePath, fit: BoxFit.contain),
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key, required this.promise});

  final Promise promise;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  promise.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                ),
                const SizedBox(height: 8.0),
                Text(
                  promise.time,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(promise: promise),
                  ),
                );
              },
              child: const Text("more"),
            ),
          ],
        ),
      ],
    );
  }
}


class CategoryFilterBar extends StatefulWidget {
  const CategoryFilterBar({super.key});

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  final List<String> categories = Category.values.map((c) => c.name).toList();
  String selectedCategory = '전체';
  String _currentSort = '최신순';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;

              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: Colors.deepPurple.shade100,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.deepPurple : Colors.black,
                ),
                side: BorderSide(
                  color: Colors.grey.shade300,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfCardsPerLine = 2;
  String _currentSort = '최신순';

  List<Promise> _getSortedPromises() {
    List<Promise> promise = PromisesRepository.loadPromises();

    if (_currentSort == '최신순') {
      promise.sort((a, b) => b.time.compareTo(a.time)); // 최신 먼저
    } else {
      promise.sort((a, b) => a.time.compareTo(b.time)); // 오래된 먼저
    }

    return promise;
  }

  List<Card> _buildCards(BuildContext context) {
    final sortedPromises = _getSortedPromises();

    if (sortedPromises.isEmpty) {
      return const <Card>[];
    }

    return sortedPromises.map((promise) {
      return Card(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: ImageWidget(promise: promise)),
              Flexible(child: InfoWidget(promise: promise)),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: 'DO\'ST'),
      body: Column(
        children: [
          SortFilter(
            currentSort: _currentSort,
            onSortChanged: (sortType) {
              setState(() {
                _currentSort = sortType;
              });
            },
          ),
          const CategoryFilterBar(), // 필요한 경우 상태 연결
          Expanded(
            child: GridView.count(
              crossAxisCount: numberOfCardsPerLine,
              padding: const EdgeInsets.all(16.0),
              childAspectRatio: 8.0 / 9.0,
              children: _buildCards(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 수정 기능
        },
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: GlobalBottomBar(),
    );
  }
}
